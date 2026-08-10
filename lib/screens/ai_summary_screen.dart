import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/constants/app_colors.dart';
import '../providers/profile_provider.dart';
import '../widgets/common_widgets.dart';

class AiSummaryScreen extends StatelessWidget {
  const AiSummaryScreen({super.key});

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
              _buildHeader(context, isDark, profile),
              Expanded(
                child: profile == null
                    ? _buildNoProfile(context)
                    : _buildSummaryContent(context, profile, isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, profile) {
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
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('AI Summary',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              Text('Auto-generated medical report',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
            ],
          ),
          const Spacer(),
          if (profile != null)
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: profile.aiSummary));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Copied to clipboard'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.copy_rounded, color: AppColors.primary, size: 18),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryContent(BuildContext context, profile, bool isDark) {
    final lines = profile.aiSummary.split('\n');
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // AI Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.psychology_rounded, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  'AI-Generated Emergency Summary',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),

          const SizedBox(height: 16),

          // Quick Stats
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Blood',
                  value: profile.bloodGroup.isEmpty ? '?' : profile.bloodGroup,
                  icon: Icons.water_drop_rounded,
                  color: AppColors.bloodRed,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  label: 'Allergies',
                  value: '${profile.allergies.length}',
                  icon: Icons.warning_rounded,
                  color: AppColors.emergency,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  label: 'BMI',
                  value: profile.bmi > 0
                      ? profile.bmi.toStringAsFixed(1)
                      : 'N/A',
                  icon: Icons.monitor_weight_rounded,
                  color: AppColors.info,
                ),
              ),
            ],
          ).animate(delay: 100.ms).fadeIn(),

          const SizedBox(height: 16),

          // Full AI Summary in styled card
          GlassCard(
            padding: const EdgeInsets.all(16),
            borderColor: AppColors.primary.withValues(alpha: 0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.description_rounded,
                          color: AppColors.primary, size: 16),
                    ),
                    const SizedBox(width: 8),
                    const Text('Full Medical Report',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: AppColors.darkBorder, height: 1),
                const SizedBox(height: 12),
                ...lines.map((line) => _buildSummaryLine(line, isDark)),
              ],
            ),
          ).animate(delay: 200.ms).fadeIn(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSummaryLine(String line, bool isDark) {
    if (line.isEmpty) return const SizedBox(height: 6);

    Color? color;
    FontWeight weight = FontWeight.normal;
    double fontSize = 13;

    if (line.contains('🆘') || line.contains('EMERGENCY')) {
      color = AppColors.emergency;
      weight = FontWeight.w800;
      fontSize = 14;
    } else if (line.contains('⚠️') || line.contains('CRITICAL') || line.contains('ALLERG')) {
      color = AppColors.emergency;
      weight = FontWeight.w700;
    } else if (line.contains('⛔')) {
      color = AppColors.emergencyLight;
      weight = FontWeight.w600;
    } else if (line.contains('🔴')) {
      color = AppColors.warning;
      weight = FontWeight.w600;
    } else if (line.contains('✅')) {
      color = AppColors.success;
    } else if (line.contains('💚') || line.contains('DONOR')) {
      color = AppColors.success;
      weight = FontWeight.w600;
    } else if (line.contains('👤') || line.contains('🩸')) {
      color = isDark ? Colors.white : AppColors.textDark;
      weight = FontWeight.w600;
    } else if (line.contains('─')) {
      color = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    } else {
      color = isDark ? Colors.white70 : Colors.black87;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Text(
        line,
        style: TextStyle(
          fontSize: fontSize,
          color: color,
          fontWeight: weight,
          fontFamily: 'monospace',
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildNoProfile(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.psychology_rounded, size: 60, color: AppColors.textMuted),
          const SizedBox(height: 16),
          const Text('No profile found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text('Create a profile to see your AI summary',
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

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 16)),
          Text(label,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
        ],
      ),
    );
  }
}
