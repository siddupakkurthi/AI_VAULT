import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../core/constants/app_colors.dart';
import '../core/router/app_router.dart';
import '../providers/profile_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/common_widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppColors.darkGradient
              : const LinearGradient(
                  colors: [Color(0xFFF5F3FF), Color(0xFFEDE9FE)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
        ),
        child: SafeArea(
          child: Consumer<ProfileProvider>(
            builder: (context, profileProvider, _) {
              final profile = profileProvider.profile;
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildHeader(context, isDark),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 8),
                        if (profile != null) ...[
                          _buildProfileCard(context, profile, isDark),
                          const SizedBox(height: 16),
                          _buildCompletionCard(context, profile, isDark),
                          const SizedBox(height: 16),
                        ] else ...[
                          _buildNoProfileCard(context, isDark),
                          const SizedBox(height: 16),
                        ],
                        _buildQuickActionsGrid(context, profile != null),
                        const SizedBox(height: 16),
                        if (profile != null) _buildRiskFlagsCard(context, profile, isDark),
                        const SizedBox(height: 90),
                      ]),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 8),
                  ShaderMask(
                    shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
                    child: const Text(
                      'AI LIFE VAULT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Emergency Medical Profile',
                style: TextStyle(
                  color: isDark ? AppColors.textMuted : Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Spacer(),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return GestureDetector(
                onTap: themeProvider.toggleTheme,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Icon(
                    themeProvider.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => context.push(AppRouter.settings),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: const Icon(Icons.settings_rounded, color: AppColors.primary, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, profile, bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      onTap: () => context.push(AppRouter.editProfile),
      child: Row(
        children: [
          // Profile Image or Avatar
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                profile.fullName.isNotEmpty
                    ? profile.fullName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName.isEmpty ? 'Your Name' : profile.fullName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${profile.age > 0 ? profile.age : '?'} yrs • ${profile.gender.isEmpty ? 'Gender' : profile.gender}',
                  style: TextStyle(
                    color: isDark ? AppColors.textMuted : Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    profile.qrId,
                    style: const TextStyle(
                      color: AppColors.primaryLight,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          BloodGroupBadge(bloodGroup: profile.bloodGroup),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2);
  }

  Widget _buildCompletionCard(BuildContext context, profile, bool isDark) {
    final percent = profile.completionPercentage;
    final color = percent < 0.5
        ? AppColors.warning
        : percent < 0.8
            ? AppColors.info
            : AppColors.success;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Profile Completion',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textMuted : Colors.grey,
                ),
              ),
              Text(
                '${(percent * 100).toInt()}%',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearPercentIndicator(
            lineHeight: 8,
            percent: percent,
            backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            progressColor: color,
            barRadius: const Radius.circular(8),
            padding: EdgeInsets.zero,
            animation: true,
            animationDuration: 1000,
          ),
          if (percent < 1.0) ...[
            const SizedBox(height: 8),
            Text(
              percent < 0.5
                  ? '⚠️ Complete your profile for better emergency response'
                  : '✅ Almost there! Fill remaining fields for complete protection',
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    ).animate(delay: 100.ms).fadeIn(duration: 500.ms);
  }

  Widget _buildNoProfileCard(BuildContext context, bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(28),
      borderColor: AppColors.primary.withValues(alpha: 0.4),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.15),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
            ),
            child: const Icon(
              Icons.person_add_rounded,
              color: AppColors.primary,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Create Your Emergency Profile',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Your medical profile could save your life. Create it now in under 2 minutes.',
            style: TextStyle(
              color: isDark ? AppColors.textMuted : Colors.grey,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          GradientButton(
            label: 'Create Profile Now',
            icon: Icons.add_circle_outline_rounded,
            onPressed: () => context.push(AppRouter.createProfile),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildQuickActionsGrid(BuildContext context, bool hasProfile) {
    final actions = [
      _QuickAction(
        icon: Icons.qr_code_rounded,
        label: 'QR Code',
        subtitle: 'Share emergency',
        color: AppColors.primary,
        route: AppRouter.qrCode,
        enabled: hasProfile,
      ),
      _QuickAction(
        icon: Icons.emergency_rounded,
        label: 'Emergency',
        subtitle: 'Preview mode',
        color: AppColors.emergency,
        route: AppRouter.emergency,
        enabled: hasProfile,
      ),
      _QuickAction(
        icon: Icons.psychology_rounded,
        label: 'AI Summary',
        subtitle: 'Auto-generated',
        color: AppColors.success,
        route: AppRouter.aiSummary,
        enabled: hasProfile,
      ),
      _QuickAction(
        icon: Icons.edit_note_rounded,
        label: 'Edit Profile',
        subtitle: 'Update info',
        color: AppColors.info,
        route: hasProfile ? AppRouter.editProfile : AppRouter.createProfile,
        enabled: true,
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: actions.asMap().entries.map((entry) {
        final i = entry.key;
        final action = entry.value;
        return _QuickActionCard(action: action)
            .animate(delay: (200 + i * 80).ms)
            .fadeIn(duration: 400.ms)
            .slideY(begin: 0.2);
      }).toList(),
    );
  }

  Widget _buildRiskFlagsCard(BuildContext context, profile, bool isDark) {
    final summary = profile.aiSummary;
    if (summary.isEmpty) return const SizedBox.shrink();

    // Extract risk flags from summary
    final lines = summary.split('\n');
    final riskLines = lines.where((String l) => l.contains('🔴')).toList();

    if (riskLines.isEmpty) {
      return GlassCard(
        padding: const EdgeInsets.all(16),
        borderColor: AppColors.success.withValues(alpha: 0.3),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.success),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI Risk Assessment',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  SizedBox(height: 2),
                  Text('No critical risk flags detected',
                      style: TextStyle(color: AppColors.success, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ).animate(delay: 400.ms).fadeIn();
    }

    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderColor: AppColors.warning.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.warning_rounded, color: AppColors.warning, size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                'AI Risk Flags',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${riskLines.length} flags',
                  style: const TextStyle(color: AppColors.warning, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...riskLines.take(3).map((line) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.circle, size: 6, color: AppColors.warning),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        line.replaceAll('  🔴 ', ''),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          if (riskLines.length > 3)
            TextButton(
              onPressed: () => context.push(AppRouter.aiSummary),
              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
              child: Text(
                'View all ${riskLines.length} flags →',
                style: const TextStyle(color: AppColors.primary, fontSize: 12),
              ),
            ),
        ],
      ),
    ).animate(delay: 400.ms).fadeIn();
  }

  Widget _buildBottomNav(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.home_rounded, label: 'Home', isActive: true, onTap: () {}),
              _NavItem(
                icon: Icons.qr_code_rounded,
                label: 'QR',
                onTap: () => context.push(AppRouter.qrCode),
              ),
              _NavItem(
                icon: Icons.emergency_rounded,
                label: 'SOS',
                isEmergency: true,
                onTap: () => context.push(AppRouter.emergency),
              ),
              _NavItem(
                icon: Icons.settings_rounded,
                label: 'Settings',
                onTap: () => context.push(AppRouter.settings),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final String route;
  final bool enabled;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.route,
    required this.enabled,
  });
}

class _QuickActionCard extends StatelessWidget {
  final _QuickAction action;

  const _QuickActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: action.enabled ? () => context.push(action.route) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: action.enabled
                ? action.color.withValues(alpha: 0.3)
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
          boxShadow: [
            BoxShadow(
              color: action.enabled
                  ? action.color.withValues(alpha: 0.1)
                  : Colors.transparent,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (action.enabled ? action.color : Colors.grey).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                action.icon,
                color: action.enabled ? action.color : Colors.grey,
                size: 20,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action.label,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: action.enabled
                        ? (isDark ? Colors.white : AppColors.textDark)
                        : Colors.grey,
                  ),
                ),
                Text(
                  action.enabled ? action.subtitle : 'Create profile first',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isEmergency;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
    this.isEmergency = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isEmergency) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: AppColors.emergencyGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.emergency.withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(height: 2),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? AppColors.primary : AppColors.textMuted,
            size: 22,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppColors.primary : AppColors.textMuted,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
