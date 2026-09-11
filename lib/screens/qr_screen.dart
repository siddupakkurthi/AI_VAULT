import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/constants/app_colors.dart';
import '../providers/profile_provider.dart';
import '../providers/hospital_provider.dart';
import '../services/sos_service.dart';
import '../widgets/common_widgets.dart';

class QrScreen extends StatelessWidget {
  const QrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = context.watch<ProfileProvider>().profile;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppColors.darkGradient : null,
          color: isDark ? null : AppColors.lightBg,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, isDark),
              Expanded(
                child: profile == null
                    ? _buildNoProfile(context)
                    : _buildQrContent(context, profile, isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.go('/dashboard'),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: isDark ? Colors.white : AppColors.textDark),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Emergency QR Code',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                Text('Scan for instant medical access',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Simulate / Input QR Scan',
            icon: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.primary),
            onPressed: () {
              final textCtrl = TextEditingController();
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: const Color(0xFF1E1035),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Row(
                    children: [
                      Icon(Icons.qr_code_scanner_rounded, color: AppColors.emergency),
                      SizedBox(width: 8),
                      Text('Scan / Input QR Payload',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Paste scanned QR payload (JSON string or Emergency ID):',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: textCtrl,
                        maxLines: 3,
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'monospace'),
                        decoration: InputDecoration(
                          hintText: '{"qrId": "EM-IND-...", "name": "..."}',
                          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 12),
                          filled: true,
                          fillColor: Colors.black26,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final input = textCtrl.text.trim();
                        Navigator.pop(ctx);
                        if (input.isNotEmpty) {
                          if (input.startsWith('{')) {
                            context.push('/emergency', extra: input);
                          } else {
                            context.push('/emergency?qrId=$input');
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.emergency),
                      child: const Text('View Profile Card', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQrContent(BuildContext context, profile, bool isDark) {
    // Public Emergency URL payload
    final emergencyUrl = 'https://blood-bank-app-9c6db.web.app/emergency/${profile.qrId}';
    final qrData = emergencyUrl;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Emergency ID Badge Card
          GlassCard(
            padding: const EdgeInsets.all(20),
            borderColor: AppColors.primary.withValues(alpha: 0.4),
            child: Column(
              children: [
                const Text(
                  'UNIVERSAL EMERGENCY ID',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppColors.primaryGradient.createShader(bounds),
                  child: Text(
                    profile.qrId,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${profile.fullName} • ${profile.bloodGroup.isEmpty ? "Blood Group N/A" : "Group ${profile.bloodGroup}"}',
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (profile.userPhone.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.phone_android_rounded, size: 12, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Patient Phone: ${profile.userPhone}',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
                if (profile.emergencyPhone.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.phone_in_talk_rounded, size: 12, color: AppColors.emergency),
                      const SizedBox(width: 4),
                      Text(
                        'ICE Contact: ${profile.emergencyContactName} (${profile.emergencyPhone})',
                        style: const TextStyle(
                          color: AppColors.emergency,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 16),

          // QR Code Card
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 210,
                    backgroundColor: Colors.white,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Color(0xFF6C3EE8),
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Color(0xFF1A0A38),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code_scanner_rounded,
                        color: AppColors.textMuted, size: 14),
                    SizedBox(width: 6),
                    Text(
                      'Scan with any phone camera or QR reader',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ).animate(delay: 100.ms).fadeIn().scale(begin: const Offset(0.95, 0.95)),

          const SizedBox(height: 16),

          // Quick SOS Actions Grid
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  title: 'Instant SOS Actions',
                  icon: Icons.flash_on_rounded,
                  iconColor: AppColors.emergency,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ActionTile(
                        icon: Icons.phone_rounded,
                        label: 'Call Contact',
                        color: AppColors.success,
                        onTap: () => SosService.makePhoneCall(profile.emergencyPhone),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ActionTile(
                        icon: Icons.message_rounded,
                        label: 'Send SOS SMS',
                        color: AppColors.emergency,
                        onTap: () => SosService.sendEmergencySms(profile),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ActionTile(
                        icon: Icons.share_rounded,
                        label: 'Share Card',
                        color: AppColors.primary,
                        onTap: () => SosService.shareEmergencyAlert(profile),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate(delay: 200.ms).fadeIn(),

          const SizedBox(height: 16),

          // Open Full Emergency Mode
          GradientButton(
            label: 'Open Public Emergency View',
            icon: Icons.emergency_rounded,
            colors: const [AppColors.emergency, AppColors.emergencyDark],
            onPressed: () => context.push('/emergency'),
          ).animate(delay: 300.ms).fadeIn(),

          const SizedBox(height: 12),

          // Find Emergency Care Nearby Button
          GradientButton(
            label: '📍 Find Emergency Care Nearby',
            icon: Icons.local_hospital_rounded,
            colors: const [Color(0xFF2563EB), Color(0xFF1D4ED8)],
            onPressed: () {
              context.read<HospitalProvider>().fetchNearbyEmergencyHospitals();
              context.push('/emergency-hospitals');
            },
          ).animate(delay: 350.ms).fadeIn(),
        ],
      ),
    );
  }

  Widget _buildNoProfile(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.qr_code_rounded, size: 60, color: AppColors.textMuted),
          const SizedBox(height: 16),
          const Text('No Profile Found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 24),
          GradientButton(
            label: 'Create Profile',
            icon: Icons.add_rounded,
            onPressed: () => context.push('/create-profile'),
            width: 200,
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
