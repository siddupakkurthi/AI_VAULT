import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';

import '../providers/profile_provider.dart';
import '../providers/hospital_provider.dart';
import '../services/firebase_service.dart';
import '../services/sos_service.dart';
import '../models/medical_profile.dart';

class EmergencyPreviewScreen extends StatefulWidget {
  final String? qrId;
  final String? rawData;

  const EmergencyPreviewScreen({
    super.key,
    this.qrId,
    this.rawData,
  });

  @override
  State<EmergencyPreviewScreen> createState() =>
      _EmergencyPreviewScreenState();
}

class _EmergencyPreviewScreenState extends State<EmergencyPreviewScreen> {
  MedicalProfile? _scannedProfile;

  bool _isLoadingScannedProfile = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _processQrData();
  }

  @override
  void didUpdateWidget(covariant EmergencyPreviewScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.qrId != widget.qrId ||
        oldWidget.rawData != widget.rawData) {
      _processQrData();
    }
  }

  // ============================================================
  // LOAD EMERGENCY PROFILE
  // ============================================================

  Future<void> _processQrData() async {
    String? targetQrId = widget.qrId;

    Map<String, dynamic>? parsedJson;

    // ------------------------------------------------------------
    // 1. Handle raw QR data / URL / old JSON QR
    // ------------------------------------------------------------

    if (widget.rawData != null &&
        widget.rawData!.trim().isNotEmpty) {
      final raw = widget.rawData!.trim();

      try {
        // New QR format:
        // https://blood-bank-app-9c6db.web.app/emergency/ABC123
        if (raw.startsWith('http://') ||
            raw.startsWith('https://')) {
          final uri = Uri.tryParse(raw);

          if (uri != null) {
            final segments = uri.pathSegments;

            final emergencyIndex =
                segments.indexOf('emergency');

            if (emergencyIndex >= 0 &&
                emergencyIndex + 1 < segments.length) {
              targetQrId = segments[emergencyIndex + 1];
            }
          }
        }

        // Old JSON QR support
        else if (raw.startsWith('{') && raw.endsWith('}')) {
          parsedJson =
              jsonDecode(raw) as Map<String, dynamic>;

          if (parsedJson.containsKey('qrId')) {
            targetQrId =
                parsedJson['qrId']?.toString();
          }
        }

        // Direct QR ID
        else {
          targetQrId = raw;
        }
      } catch (e) {
        debugPrint('Error parsing QR data: $e');
      }
    }

    // ------------------------------------------------------------
    // 2. Wait for Firebase initialization
    // ------------------------------------------------------------

    int attempts = 0;

    while (!FirebaseService.isInitialized &&
        attempts < 20) {
      await Future.delayed(
        const Duration(milliseconds: 250),
      );

      attempts++;
    }

    // ------------------------------------------------------------
    // 3. Fetch profile from Firebase
    // ------------------------------------------------------------

    if (targetQrId != null &&
        targetQrId.trim().isNotEmpty) {
      if (mounted) {
        setState(() {
          _isLoadingScannedProfile = true;
          _errorMessage = null;
        });
      }

      try {
        // Public emergency access.
        // This does NOT require the person scanning
        // the QR to create a normal account.

        final fetched =
            await FirebaseService.getProfileByQrId(
          targetQrId.trim(),
        );

        if (!mounted) return;

        if (fetched != null) {
          setState(() {
            _scannedProfile = fetched;
            _isLoadingScannedProfile = false;
            _errorMessage = null;
          });

          return;
        }
      } catch (e) {
        debugPrint(
          'Error loading emergency profile: $e',
        );

        if (mounted) {
          setState(() {
            _errorMessage =
                'Unable to load emergency profile.\n'
                'Please check your internet connection.';
          });
        }
      }
    }

    // ------------------------------------------------------------
    // 4. Old JSON fallback
    // ------------------------------------------------------------

    if (parsedJson != null) {
      try {
        final parsedProfile =
            MedicalProfile.fromJson(parsedJson);

        if (!mounted) return;

        setState(() {
          _scannedProfile = parsedProfile;
          _isLoadingScannedProfile = false;
          _errorMessage = null;
        });

        return;
      } catch (e) {
        debugPrint(
          'Failed converting JSON to profile: $e',
        );
      }
    }

    // ------------------------------------------------------------
    // 5. Error
    // ------------------------------------------------------------

    if (!mounted) return;

    setState(() {
      _isLoadingScannedProfile = false;

      if (targetQrId != null &&
          targetQrId.isNotEmpty) {
        _errorMessage ??=
            'Emergency profile not found';
      } else {
        _errorMessage ??=
            'Invalid Emergency QR';
      }
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final localProfile =
        context.watch<ProfileProvider>().profile;

    final profile =
        _scannedProfile ?? localProfile;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: const Color(0xFFB91C1C),
        elevation: 0,

        leading: context.canPop()
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                ),
                onPressed: () {
                  context.pop();
                },
              )
            : null,

        title: const Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              'AI LIFE VAULT',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              'Emergency Medical ID',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: _isLoadingScannedProfile
          ? _buildLoading()
          : profile == null
              ? _buildNoProfileState()
              : _buildEmergencyPage(profile),
    );
  }

  // ============================================================
  // LOADING
  // ============================================================

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Color(0xFFB91C1C),
          ),
          SizedBox(height: 18),
          Text(
            'Loading Emergency Medical Profile...',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MAIN EMERGENCY PAGE
  // ============================================================

  Widget _buildEmergencyPage(
    MedicalProfile profile,
  ) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: ConstrainedBox(
          constraints:
              const BoxConstraints(
            maxWidth: 700,
          ),

          child: Column(
            children: [
              // --------------------------------------------------
              // EMERGENCY HEADER
              // --------------------------------------------------

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(22),

                decoration: BoxDecoration(
                  color: const Color(0xFFB91C1C),
                  borderRadius:
                      const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red
                          .withValues(alpha: 0.18),
                      blurRadius: 20,
                      offset:
                          const Offset(0, 8),
                    ),
                  ],
                ),

                child: const Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor:
                          Colors.white24,
                      child: Icon(
                        Icons.favorite_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'EMERGENCY MEDICAL ID',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'AI Life Vault • Emergency Response',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // --------------------------------------------------
              // PATIENT IDENTITY
              // --------------------------------------------------

              _card(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PATIENT',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      profile.fullName,
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 26,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      '${profile.age} years • ${profile.gender}',
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // --------------------------------------------------
              // BLOOD GROUP
              // --------------------------------------------------

              _card(
                child: Row(
                  children: [
                    _iconBox(
                      Icons.bloodtype_rounded,
                      const Color(0xFFDC2626),
                    ),

                    const SizedBox(width: 15),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BLOOD GROUP',
                            style: TextStyle(
                              color:
                                  Color(0xFF6B7280),
                              fontSize: 11,
                              fontWeight:
                                  FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Text(
                      profile.bloodGroup,
                      style: const TextStyle(
                        color: Color(0xFFB91C1C),
                        fontSize: 30,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),

              // --------------------------------------------------
              // ALLERGIES
              // --------------------------------------------------

              _medicalSection(
                title: 'CRITICAL ALLERGIES',
                icon: Icons.warning_amber_rounded,
                color: const Color(0xFFDC2626),
                items: profile.allergies,
                emptyText:
                    'No known allergies',
                highlighted: true,
              ),

              // --------------------------------------------------
              // CONDITIONS
              // --------------------------------------------------

              _medicalSection(
                title: 'MEDICAL CONDITIONS',
                icon: Icons.local_hospital_rounded,
                color: const Color(0xFF7C3AED),
                items: profile.diseases,
                emptyText:
                    'No conditions listed',
              ),

              // --------------------------------------------------
              // MEDICATIONS
              // --------------------------------------------------

              _medicalSection(
                title: 'CURRENT MEDICATIONS',
                icon: Icons.medication_rounded,
                color: const Color(0xFF2563EB),
                items: profile.medications,
                emptyText:
                    'No medications listed',
              ),

              // --------------------------------------------------
              // ORGAN DONOR
              // --------------------------------------------------

              if (profile.isOrganDonor)
                _card(
                  color: const Color(0xFFECFDF5),
                  borderColor:
                      const Color(0xFF10B981),
                  child: Row(
                    children: [
                      _iconBox(
                        Icons.volunteer_activism_rounded,
                        const Color(0xFF059669),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ORGAN DONOR',
                              style: TextStyle(
                                color:
                                    Color(0xFF047857),
                                fontSize: 11,
                                fontWeight:
                                    FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Registered organ donor',
                              style: TextStyle(
                                color:
                                    Color(0xFF065F46),
                                fontSize: 15,
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // --------------------------------------------------
              // MEDICAL NOTES
              // --------------------------------------------------

              if (profile.medicalNotes
                  .trim()
                  .isNotEmpty)
                _card(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      _sectionTitle(
                        Icons.notes_rounded,
                        'MEDICAL NOTES',
                        const Color(0xFF475569),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        profile.medicalNotes,
                        style: const TextStyle(
                          color: Color(0xFF374151),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

              // --------------------------------------------------
              // AI SUMMARY
              // --------------------------------------------------

              _card(
                color: const Color(0xFFF5F3FF),
                borderColor:
                    const Color(0xFF8B5CF6),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _sectionTitle(
                      Icons.auto_awesome_rounded,
                      'AI EMERGENCY SUMMARY',
                      const Color(0xFF7C3AED),
                    ),

                    const SizedBox(height: 14),

                    Text(
                      _generateLocalSummary(
                        profile,
                      ),
                      style: const TextStyle(
                        color: Color(0xFF312E81),
                        fontSize: 14,
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),

              // --------------------------------------------------
              // EMERGENCY CONTACT
              // --------------------------------------------------

              _card(
                color: const Color(0xFFFFF7ED),
                borderColor:
                    const Color(0xFFF97316),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _sectionTitle(
                      Icons.phone_in_talk_rounded,
                      'EMERGENCY CONTACT',
                      const Color(0xFFEA580C),
                    ),

                    const SizedBox(height: 14),

                    Text(
                      profile.emergencyContactName,
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 18,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      profile.relationship,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _callEmergencyContact(
                          profile.emergencyPhone,
                        ),

                        icon: const Icon(
                          Icons.call_rounded,
                        ),

                        label: Text(
                          'CALL ${profile.emergencyContactName}',
                        ),

                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF16A34A),
                          foregroundColor:
                              Colors.white,
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            vertical: 15,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // --------------------------------------------------
              // FIND EMERGENCY CARE NEARBY (FOR QR RESPONDERS)
              // --------------------------------------------------

              _card(
                color: const Color(0xFFFEF2F2),
                borderColor: const Color(0xFFEF4444),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFB91C1C),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            '🚨 FOR RESPONDERS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'NEARBY EMERGENCY CARE',
                            style: TextStyle(
                              color: Color(0xFFB91C1C),
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'Find hospitals, trauma centers, and emergency care near your current location.',
                      style: TextStyle(
                        color: Color(0xFF1F2937),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 14),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.read<HospitalProvider>().fetchNearbyEmergencyHospitals();
                          context.push('/emergency-hospitals');
                        },
                        icon: const Icon(
                          Icons.location_on_rounded,
                          size: 20,
                        ),
                        label: const Text(
                          '📍 Find Emergency Care Nearby',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB91C1C),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              12,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.near_me_rounded, size: 13, color: Color(0xFF6B7280)),
                          SizedBox(width: 4),
                          Text(
                            'Uses scanner\'s live GPS location • No patient tracking',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // --------------------------------------------------
              // FOOTER
              // --------------------------------------------------

              const SizedBox(height: 10),

              Text(
                'AI LIFE VAULT',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                'Emergency information • Scan to view',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 11,
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CARD
  // ============================================================

  Widget _card({
    required Widget child,
    Color color = Colors.white,
    Color? borderColor,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: color,
        borderRadius:
            BorderRadius.circular(16),

        border: Border.all(
          color: borderColor ??
              const Color(0xFFE5E7EB),
        ),

        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),

      child: child,
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(
    IconData icon,
    String title,
    Color color,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        const SizedBox(width: 9),
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ICON BOX
  // ============================================================

  Widget _iconBox(
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 46,
      height: 46,

      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.10,
        ),
        borderRadius:
            BorderRadius.circular(12),
      ),

      child: Icon(
        icon,
        color: color,
        size: 25,
      ),
    );
  }

  // ============================================================
  // MEDICAL SECTION
  // ============================================================

  Widget _medicalSection({
    required String title,
    required IconData icon,
    required Color color,
    required List items,
    required String emptyText,
    bool highlighted = false,
  }) {
    return _card(
      color: highlighted
          ? const Color(0xFFFFF1F2)
          : Colors.white,

      borderColor: highlighted
          ? const Color(0xFFFCA5A5)
          : null,

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          _sectionTitle(
            icon,
            title,
            color,
          ),

          const SizedBox(height: 13),

          if (items.isEmpty)
            Text(
              emptyText,
              style: TextStyle(
                color: highlighted
                    ? const Color(0xFF991B1B)
                    : const Color(0xFF6B7280),
                fontSize: 14,
                fontWeight:
                    FontWeight.w500,
              ),
            )
          else
            ...items.map(
              (item) => Container(
                width: double.infinity,
                margin:
                    const EdgeInsets.only(
                  bottom: 7,
                ),

                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(
                    9,
                  ),
                  border: Border.all(
                    color:
                        color.withValues(
                      alpha: 0.20,
                    ),
                  ),
                ),

                child: Row(
                  children: [
                    Icon(
                      highlighted
                          ? Icons.warning_rounded
                          : Icons.circle,
                      color: color,
                      size:
                          highlighted ? 17 : 7,
                    ),

                    const SizedBox(width: 9),

                    Expanded(
                      child: Text(
                        item.toString(),
                        style:
                            const TextStyle(
                          color:
                              Color(0xFF374151),
                          fontSize: 14,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // OFFLINE AI SUMMARY
  // ============================================================

  String _generateLocalSummary(
    MedicalProfile profile,
  ) {
    final parts = <String>[];

    parts.add(
      '${profile.fullName} is a '
      '${profile.age}-year-old '
      '${profile.gender} patient.',
    );

    parts.add(
      'Blood group: ${profile.bloodGroup}.',
    );

    if (profile.allergies.isNotEmpty) {
      parts.add(
        'Critical allergies: '
        '${profile.allergies.join(', ')}.',
      );
    } else {
      parts.add(
        'No known allergies listed.',
      );
    }

    if (profile.diseases.isNotEmpty) {
      parts.add(
        'Medical conditions: '
        '${profile.diseases.join(', ')}.',
      );
    }

    if (profile.medications.isNotEmpty) {
      parts.add(
        'Current medications: '
        '${profile.medications.join(', ')}.',
      );
    }

    if (profile.isOrganDonor) {
      parts.add(
        'Registered organ donor.',
      );
    }

    return parts.join(' ');
  }

  // ============================================================
  // CALL EMERGENCY CONTACT
  // ============================================================

  void _callEmergencyContact(
    String phone,
  ) {
    final cleaned = phone.trim();

    if (cleaned.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Emergency contact number is not available. Dialing 108...',
          ),
        ),
      );
      SosService.makePhoneCall('108');
      return;
    }

    // 1. Copy number to clipboard
    Clipboard.setData(
      ClipboardData(
        text: cleaned,
      ),
    );

    // 2. Launch system phone dialer directly
    SosService.makePhoneCall(cleaned);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Dialing $cleaned...',
        ),
        backgroundColor: const Color(0xFF16A34A),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildNoProfileState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            const Icon(
              Icons
                  .emergency_rounded,
              size: 70,
              color: Color(0xFFDC2626),
            ),

            const SizedBox(height: 18),

            Text(
              _errorMessage ??
                  'Emergency profile not found',

              style: const TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.w800,
                color: Color(0xFF111827),
              ),

              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10),

            const Text(
              'Please verify the emergency QR code and try again.',

              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 13,
              ),

              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed:
                  _processQrData,

              icon: const Icon(
                Icons.refresh_rounded,
              ),

              label: const Text(
                'Retry',
              ),

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFFB91C1C),
                foregroundColor:
                    Colors.white,
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 24,
                  vertical: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
