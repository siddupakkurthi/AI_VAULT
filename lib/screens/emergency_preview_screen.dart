import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/constants/app_colors.dart';
import '../providers/profile_provider.dart';
import '../services/sos_service.dart';
import '../widgets/common_widgets.dart';

class EmergencyPreviewScreen extends StatefulWidget {
  const EmergencyPreviewScreen({super.key});

  @override
  State<EmergencyPreviewScreen> createState() => _EmergencyPreviewScreenState();
}

class _EmergencyPreviewScreenState extends State<EmergencyPreviewScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;

    return Scaffold(
      backgroundColor: const Color(0xFF07020D),
      body: SafeArea(
        child: profile == null
            ? _buildNoProfile(context)
            : _buildEmergencyContent(context, profile),
      ),
    );
  }

  Widget _buildEmergencyContent(BuildContext context, profile) {
    return Column(
      children: [
        // Flashing Paramedic Emergency Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFB91C1C), Color(0xFF991B1B), Color(0xFF450A0A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFDC2626),
                blurRadius: 15,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go('/dashboard'),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                  ),
                  const Spacer(),
                  AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (_, child) => Transform.scale(
                      scale: 1.0 + (_pulseCtrl.value * 0.12),
                      child: child,
                    ),
                    child: const Icon(Icons.warning_amber_rounded,
                        color: Colors.yellowAccent, size: 22),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'FIRST RESPONDER EMERGENCY VIEW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 28),
                ],
              ),
              const SizedBox(height: 14),

              // Patient Primary Profile Card
              Row(
                children: [
                  // Profile Avatar / Initials
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        profile.fullName.isNotEmpty
                            ? profile.fullName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Color(0xFFB91C1C),
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Name & Demographics
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.fullName.isEmpty ? 'Anonymous Patient' : profile.fullName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${profile.age} yrs • ${profile.gender}${profile.height > 0 ? ' • ${profile.height.toInt()}cm' : ''}${profile.weight > 0 ? ' • ${profile.weight.toInt()}kg' : ''}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Giant High-Visibility Blood Group Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          profile.bloodGroup.isEmpty ? '?' : profile.bloodGroup,
                          style: const TextStyle(
                            color: Color(0xFFB91C1C),
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                        ),
                        const Text(
                          'BLOOD',
                          style: TextStyle(
                            color: Color(0xFFB91C1C),
                            fontWeight: FontWeight.w800,
                            fontSize: 9,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // High-Visibility Medical Data Body
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ⚠️ CRITICAL ALLERGIES (Red High-Alert Box)
                if (profile.allergies.isNotEmpty)
                  _buildEmergencyAlertBox(
                    title: '⛔ CRITICAL ALLERGIES — DO NOT ADMINISTER',
                    items: profile.allergies,
                    color: const Color(0xFFEF4444),
                    bgColor: const Color(0xFF2A0808),
                    borderColor: const Color(0xFFEF4444),
                    icon: Icons.cancel_rounded,
                  ).animate().fadeIn(duration: 300.ms)
                else
                  _buildEmergencyAlertBox(
                    title: '✅ NO KNOWN ALLERGIES RECORDED',
                    items: [],
                    color: const Color(0xFF10B981),
                    bgColor: const Color(0xFF042F2E),
                    borderColor: const Color(0xFF10B981),
                    icon: Icons.check_circle_rounded,
                  ).animate().fadeIn(),

                const SizedBox(height: 12),

                // 🏥 EXISTING CONDITIONS (Amber Alert Box)
                if (profile.diseases.isNotEmpty)
                  _buildEmergencyAlertBox(
                    title: '🏥 MEDICAL CONDITIONS & DIAGNOSES',
                    items: profile.diseases,
                    color: const Color(0xFBF59E0B),
                    bgColor: const Color(0xFF2E1C04),
                    borderColor: const Color(0xFBF59E0B),
                    icon: Icons.local_hospital_rounded,
                  ).animate(delay: 100.ms).fadeIn(),

                if (profile.diseases.isNotEmpty) const SizedBox(height: 12),

                // 💊 CURRENT MEDICATIONS (Blue Alert Box)
                if (profile.medications.isNotEmpty)
                  _buildEmergencyAlertBox(
                    title: '💊 CURRENT MEDICATIONS',
                    items: profile.medications,
                    color: const Color(0xFF3B82F6),
                    bgColor: const Color(0xFF091E42),
                    borderColor: const Color(0xFF3B82F6),
                    icon: Icons.medication_rounded,
                  ).animate(delay: 150.ms).fadeIn(),

                if (profile.medications.isNotEmpty) const SizedBox(height: 12),

                // 💚 ORGAN DONOR STATUS
                if (profile.isOrganDonor)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF064E3B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF10B981), width: 1.5),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.favorite_rounded, color: Color(0xFF10B981), size: 20),
                        SizedBox(width: 10),
                        Text(
                          '💚 REGISTERED ORGAN DONOR',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ).animate(delay: 200.ms).fadeIn(),

                if (profile.isOrganDonor) const SizedBox(height: 12),

                // 🤖 AI EMERGENCY SUMMARY
                if (profile.aiSummary.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1035),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.psychology_rounded, color: Color(0xFFA78BFA), size: 18),
                            SizedBox(width: 8),
                            Text(
                              'AI CLINICAL RISK ASSESSMENT',
                              style: TextStyle(
                                color: Color(0xFFA78BFA),
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          profile.aiSummary,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            height: 1.5,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ).animate(delay: 250.ms).fadeIn(),

                const SizedBox(height: 20),

                // Emergency ID Tag
                Text(
                  'Emergency Profile ID: ${profile.qrId}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    letterSpacing: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        // Pinned Bottom SOS Action Buttons Bar
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: const BoxDecoration(
            color: Color(0xFF0F071A),
            border: Border(top: BorderSide(color: Color(0xFF241848))),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => SosService.makePhoneCall(profile.emergencyPhone),
                      icon: const Icon(Icons.phone_in_talk_rounded, color: Colors.white, size: 18),
                      label: Text(
                        'CALL ${profile.emergencyContactName.toUpperCase().split(' ').first}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => SosService.sendEmergencySms(profile),
                      icon: const Icon(Icons.emergency_share_rounded, color: Colors.white, size: 18),
                      label: const Text(
                        'SEND SOS SMS',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyAlertBox({
    required String title,
    required List<String> items,
    required Color color,
    required Color bgColor,
    required Color borderColor,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          if (items.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: items
                  .map((item) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: color.withValues(alpha: 0.6)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, size: 6, color: color),
                            const SizedBox(width: 6),
                            Text(
                              item,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNoProfile(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.emergency_rounded, size: 60, color: AppColors.emergency),
          const SizedBox(height: 16),
          const Text('No Emergency Profile',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 8),
          const Text('Create your profile to enable emergency mode',
              style: TextStyle(color: AppColors.textMuted)),
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
