import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants/app_colors.dart';
import '../models/hospital_model.dart';
import '../providers/hospital_provider.dart';
import '../services/sos_service.dart';

class EmergencyHospitalsScreen extends StatefulWidget {
  const EmergencyHospitalsScreen({super.key});

  @override
  State<EmergencyHospitalsScreen> createState() => _EmergencyHospitalsScreenState();
}

class _EmergencyHospitalsScreenState extends State<EmergencyHospitalsScreen> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<HospitalProvider>();
      if (provider.status == HospitalSearchStatus.idle) {
        provider.fetchNearbyEmergencyHospitals();
      }
    });
  }

  Future<void> _openDirections(double userLat, double userLng, double destLat, double destLng) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&origin=$userLat,$userLng&destination=$destLat,$destLng&travelmode=driving',
    );
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri);
      }
    } catch (e) {
      debugPrint('Error launching map directions: $e');
    }
  }

  void _callHospital(Hospital hospital) {
    final phoneToCall = hospital.phone.trim().isNotEmpty ? hospital.phone.trim() : '108';
    SosService.makePhoneCall(phoneToCall);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling ${hospital.name.isEmpty ? "Emergency Care" : hospital.name} ($phoneToCall)...'),
        backgroundColor: const Color(0xFF16A34A),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB91C1C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/emergency');
            }
          },
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Emergency Hospitals',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              'Emergency care near your current location',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
      body: Consumer<HospitalProvider>(
        builder: (context, provider, child) {
          switch (provider.status) {
            case HospitalSearchStatus.loadingLocation:
              return _buildLoadingState('Getting your current location...');
            case HospitalSearchStatus.searchingHospitals:
              return _buildLoadingState('Finding emergency care nearby...');
            case HospitalSearchStatus.permissionDenied:
              return _buildErrorState(
                icon: Icons.location_off_rounded,
                title: 'Location Permission Required',
                message: provider.errorMessage ??
                    'Location permission is required to find emergency care near you.',
                buttonText: 'Enable Location',
                onPressed: () => provider.fetchNearbyEmergencyHospitals(),
              );
            case HospitalSearchStatus.locationDisabled:
              return _buildErrorState(
                icon: Icons.location_disabled_rounded,
                title: 'Location Services Disabled',
                message: provider.errorMessage ??
                    'Please enable location services to find emergency care nearby.',
                buttonText: 'Enable Location Services',
                onPressed: () => provider.openLocationSettings(),
              );
            case HospitalSearchStatus.noHospitals:
              return _buildErrorState(
                icon: Icons.local_hospital_outlined,
                title: 'No Hospitals Found',
                message: provider.errorMessage ??
                    'No nearby emergency hospitals were found.',
                buttonText: 'Try Again',
                onPressed: () => provider.fetchNearbyEmergencyHospitals(),
              );
            case HospitalSearchStatus.error:
              return _buildErrorState(
                icon: Icons.wifi_off_rounded,
                title: 'Connection Error',
                message: provider.errorMessage ??
                    'Unable to load nearby emergency care. Please check your internet connection.',
                buttonText: 'Retry',
                onPressed: () => provider.fetchNearbyEmergencyHospitals(),
              );
            case HospitalSearchStatus.success:
              return _buildHospitalMapAndList(context, provider, isDark);
            case HospitalSearchStatus.idle:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  Widget _buildLoadingState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFFB91C1C),
          ),
          const SizedBox(height: 18),
          Text(
            message,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState({
    required IconData icon,
    required String title,
    required String message,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: const Color(0xFFDC2626),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 13,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(buttonText),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB91C1C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHospitalMapAndList(
    BuildContext context,
    HospitalProvider provider,
    bool isDark,
  ) {
    final uLat = provider.responderLat!;
    final uLng = provider.responderLng!;
    final hospitals = provider.hospitals;

    return Column(
      children: [
        // ----------------------------------------------------
        // TOP INTERACTIVE MAP
        // ----------------------------------------------------
        SizedBox(
          height: 280,
          child: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: LatLng(uLat, uLng),
                  initialZoom: 14.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.ai_life_vault',
                  ),
                  MarkerLayer(
                    markers: [
                      // Responder Marker (📍 You)
                      Marker(
                        point: LatLng(uLat, uLng),
                        width: 50,
                        height: 50,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1035),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '📍 You',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.my_location_rounded,
                              color: Color(0xFF7C3AED),
                              size: 28,
                            ),
                          ],
                        ),
                      ),
                      // Hospital Markers
                      ...hospitals.map((h) {
                        final isSelected = provider.selectedHospital?.id == h.id;
                        return Marker(
                          point: LatLng(h.latitude, h.longitude),
                          width: 48,
                          height: 48,
                          child: GestureDetector(
                            onTap: () {
                              provider.selectHospital(h);
                              _mapController.move(LatLng(h.latitude, h.longitude), 15.0);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              transform: isSelected ? Matrix4.diagonal3Values(1.2, 1.2, 1) : Matrix4.identity(),
                              child: CircleAvatar(
                                backgroundColor: isSelected ? const Color(0xFFB91C1C) : const Color(0xFFDC2626),
                                child: const Icon(
                                  Icons.local_hospital_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
              Positioned(
                bottom: 12,
                right: 12,
                child: FloatingActionButton.small(
                  heroTag: 'recenter_location',
                  backgroundColor: const Color(0xFFB91C1C),
                  child: const Icon(Icons.my_location_rounded, color: Colors.white),
                  onPressed: () {
                    _mapController.move(LatLng(uLat, uLng), 14.0);
                  },
                ),
              ),
            ],
          ),
        ),

        // ----------------------------------------------------
        // HOSPITAL LIST BELOW MAP
        // ----------------------------------------------------
        Expanded(
          child: Container(
            color: isDark ? AppColors.darkBg : const Color(0xFFF4F7FB),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'NEAREST EMERGENCY HOSPITALS (${hospitals.length})',
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const Row(
                        children: [
                          Icon(Icons.sort_rounded, size: 14, color: Color(0xFF6B7280)),
                          SizedBox(width: 4),
                          Text(
                            'Sorted by distance',
                            style: TextStyle(color: Color(0xFF6B7280), fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemCount: hospitals.length,
                    itemBuilder: (context, index) {
                      final hospital = hospitals[index];
                      final isSelected = provider.selectedHospital?.id == hospital.id;

                      return GestureDetector(
                        onTap: () {
                          provider.selectHospital(hospital);
                          _mapController.move(
                            LatLng(hospital.latitude, hospital.longitude),
                            15.0,
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkCard : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFB91C1C)
                                  : (isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB)),
                              width: isSelected ? 2.0 : 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFB91C1C).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.local_hospital_rounded,
                                      color: Color(0xFFB91C1C),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          hospital.name,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? Colors.white : const Color(0xFF111827),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFDC2626).withValues(alpha: 0.12),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                hospital.formattedDistance,
                                                style: const TextStyle(
                                                  color: Color(0xFFB91C1C),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF16A34A).withValues(alpha: 0.12),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                hospital.openStatus,
                                                style: const TextStyle(
                                                  color: Color(0xFF15803D),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (hospital.address.trim().isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Text(
                                  hospital.address,
                                  style: TextStyle(
                                    color: isDark ? Colors.white70 : const Color(0xFF4B5563),
                                    fontSize: 12,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _callHospital(hospital),
                                      icon: const Icon(Icons.call_rounded, size: 16),
                                      label: const Text('Call'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(0xFF16A34A),
                                        side: const BorderSide(color: Color(0xFF16A34A)),
                                        padding: const EdgeInsets.symmetric(vertical: 11),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => _openDirections(
                                        uLat,
                                        uLng,
                                        hospital.latitude,
                                        hospital.longitude,
                                      ),
                                      icon: const Icon(Icons.directions_rounded, size: 16),
                                      label: const Text('Directions'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF2563EB),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 11),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
