import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/constants/app_colors.dart';
import '../widgets/common_widgets.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppColors.darkGradient : null,
          color: isDark ? null : AppColors.lightBg,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header
                Padding(
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
                            border: Border.all(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder),
                          ),
                          child: Icon(Icons.arrow_back_ios_new_rounded,
                              size: 16,
                              color: isDark ? Colors.white : AppColors.textDark),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text('About',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),

                // Hero Section
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.favorite_rounded,
                            color: Colors.white, size: 40),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'AI LIFE VAULT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Your Emergency. Our Priority.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Version 1.0.0 • MVP Release',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Problem Statement
                      GlassCard(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionHeader(
                              title: 'The Problem',
                              icon: Icons.report_problem_rounded,
                              iconColor: AppColors.emergency,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Millions of people suffer medical emergencies where they are unconscious or unable to communicate. Doctors lack instant access to critical info like blood group, allergies, and medications — leading to delayed treatment and preventable fatalities.',
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black87,
                                fontSize: 13,
                                height: 1.7,
                              ),
                            ),
                          ],
                        ),
                      ).animate(delay: 100.ms).fadeIn(),

                      const SizedBox(height: 14),

                      // Solution
                      GlassCard(
                        padding: const EdgeInsets.all(18),
                        borderColor: AppColors.success.withValues(alpha: 0.3),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionHeader(
                              title: 'Our Solution',
                              icon: Icons.lightbulb_rounded,
                              iconColor: AppColors.success,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'AI Life Vault provides a secure, offline emergency medical identity with AI-generated health summary and QR-based access — enabling first responders to obtain life-saving information instantly.',
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black87,
                                fontSize: 13,
                                height: 1.7,
                              ),
                            ),
                          ],
                        ),
                      ).animate(delay: 150.ms).fadeIn(),

                      const SizedBox(height: 14),

                      // Key Features
                      GlassCard(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionHeader(
                              title: 'Key Features',
                              icon: Icons.star_rounded,
                              iconColor: AppColors.warning,
                            ),
                            const SizedBox(height: 14),
                            ..._features.map((f) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: f.color.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(f.icon, color: f.color, size: 16),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(f.title,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13)),
                                            Text(f.desc,
                                                style: const TextStyle(
                                                    color: AppColors.textMuted,
                                                    fontSize: 11)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ).animate(delay: 200.ms).fadeIn(),

                      const SizedBox(height: 14),

                      // Tech Stack
                      GlassCard(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionHeader(
                              title: 'Tech Stack',
                              icon: Icons.code_rounded,
                              iconColor: AppColors.info,
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                'Flutter', 'Provider', 'Hive', 'Go Router',
                                'qr_flutter', 'Material 3', 'Offline First',
                              ].map((t) => InfoChip(
                                    label: t,
                                    color: AppColors.info,
                                    icon: Icons.check_rounded,
                                  )).toList(),
                            ),
                          ],
                        ),
                      ).animate(delay: 250.ms).fadeIn(),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static final _features = [
    _Feature(
      icon: Icons.flash_on_rounded,
      title: 'Instant Access',
      desc: 'Critical info within seconds',
      color: AppColors.warning,
    ),
    _Feature(
      icon: Icons.wifi_off_rounded,
      title: 'Offline Functionality',
      desc: 'Works without internet',
      color: AppColors.success,
    ),
    _Feature(
      icon: Icons.psychology_rounded,
      title: 'AI-Assisted Summary',
      desc: 'Rule-based risk assessment',
      color: AppColors.primary,
    ),
    _Feature(
      icon: Icons.qr_code_rounded,
      title: 'QR-Based Emergency Access',
      desc: 'Scan for instant information',
      color: AppColors.info,
    ),
    _Feature(
      icon: Icons.shield_rounded,
      title: 'Privacy-Focused',
      desc: 'All data stored locally',
      color: AppColors.emergency,
    ),
    _Feature(
      icon: Icons.cloud_upload_rounded,
      title: 'Future-Ready Architecture',
      desc: 'Backend integration ready',
      color: AppColors.primaryLight,
    ),
  ];
}

class _Feature {
  final IconData icon;
  final String title;
  final String desc;
  final Color color;

  const _Feature({
    required this.icon,
    required this.title,
    required this.desc,
    required this.color,
  });
}
