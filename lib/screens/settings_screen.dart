import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import '../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/theme_provider.dart';
import '../services/firebase_service.dart';
import '../widgets/common_widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
          child: Column(
            children: [
              _buildHeader(context, isDark),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    children: [
                      _buildAccountSection(context, isDark),
                      const SizedBox(height: 16),
                      _buildProfileSection(context, isDark),
                      const SizedBox(height: 16),
                      _buildAppearanceSection(context, isDark),
                      const SizedBox(height: 16),
                      _buildInfoSection(context, isDark),
                      const SizedBox(height: 24),
                      _buildDangerZoneSection(context, isDark),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
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
          const Text('Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context, bool isDark) {
    final firebaseOk = FirebaseService.isInitialized;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: 'ACCOUNT & CLOUD BACKEND', icon: Icons.cloud_done_rounded),
          const SizedBox(height: 12),
          Consumer2<AuthProvider, ProfileProvider>(
            builder: (context, authProvider, profileProvider, _) {
              final statusText = firebaseOk
                  ? (profileProvider.isCloudSynced ? 'Synced to Cloud' : 'Cloud Enabled (Pending Sync)')
                  : 'Offline Storage Mode';
              final statusColor = firebaseOk
                  ? (profileProvider.isCloudSynced ? AppColors.success : AppColors.info)
                  : AppColors.warning;

              return Column(
                children: [
                  _SettingsTile(
                    icon: Icons.account_circle_rounded,
                    label: 'Account Status',
                    subtitle: authProvider.isAuthenticated
                        ? '${authProvider.userEmail} (${authProvider.isAnonymous ? "Guest" : "Registered"})'
                        : 'Not signed in',
                    iconColor: AppColors.primary,
                    trailing: authProvider.isAuthenticated
                        ? OutlinedButton(
                            onPressed: () async {
                              await authProvider.signOut();
                              profileProvider.clearProfileState();
                              if (context.mounted) context.go('/login');
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.emergency,
                              side: const BorderSide(color: AppColors.emergency),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                            ),
                            child: const Text('Sign Out', style: TextStyle(fontSize: 11)),
                          )
                        : ElevatedButton(
                            onPressed: () => context.go('/login'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            ),
                            child: const Text('Sign In', style: TextStyle(fontSize: 11)),
                          ),
                  ),
                  const Divider(height: 16),
                  _SettingsTile(
                    icon: Icons.sync_rounded,
                    label: 'Cloud Sync Status',
                    subtitle: profileProvider.isCloudSyncing
                        ? 'Syncing with Cloud Firestore...'
                        : statusText,
                    iconColor: statusColor,
                    onTap: profileProvider.hasProfile && !profileProvider.isCloudSyncing
                        ? () async {
                            final success = await profileProvider.syncToCloud();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(success
                                      ? '✅ Profile synced to Cloud Firestore!'
                                      : '⚠️ Cloud sync failed. Working offline.'),
                                  backgroundColor: success ? AppColors.success : AppColors.warning,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        : null,
                    trailing: profileProvider.isCloudSyncing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              firebaseOk ? 'ONLINE' : 'OFFLINE',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: statusColor),
                            ),
                          ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildProfileSection(BuildContext context, bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: 'MEDICAL PROFILE DATA', icon: Icons.folder_shared_rounded),
          const SizedBox(height: 12),
          Consumer<ProfileProvider>(
            builder: (context, profileProvider, _) {
              return Column(
                children: [
                  _SettingsTile(
                    icon: Icons.edit_rounded,
                    label: profileProvider.hasProfile ? 'Edit Medical Profile' : 'Create Profile',
                    subtitle: profileProvider.hasProfile
                        ? 'Update medical info, allergies & contacts'
                        : 'Set up emergency profile',
                    onTap: () => context.push(
                      profileProvider.hasProfile
                          ? '/edit-profile'
                          : '/create-profile',
                    ),
                    iconColor: AppColors.primary,
                  ),
                  const Divider(height: 16),
                  _SettingsTile(
                    icon: Icons.share_rounded,
                    label: 'Export Profile (JSON)',
                    subtitle: 'Share encrypted medical profile',
                    onTap: profileProvider.hasProfile
                        ? () => _exportProfile(context, profileProvider)
                        : null,
                    iconColor: AppColors.success,
                  ),
                  const Divider(height: 16),
                  _SettingsTile(
                    icon: Icons.file_download_outlined,
                    label: 'Import Profile (JSON)',
                    subtitle: 'Load profile from JSON data',
                    onTap: () => _showImportDialog(context, profileProvider),
                    iconColor: AppColors.info,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    ).animate(delay: 100.ms).fadeIn();
  }

  Widget _buildAppearanceSection(BuildContext context, bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: 'PREFERENCES', icon: Icons.palette_rounded),
          const SizedBox(height: 12),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return _SettingsTile(
                icon: themeProvider.isDarkMode
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                label: 'Dark Mode Theme',
                subtitle: themeProvider.isDarkMode ? 'Dark visual mode active' : 'Light visual mode active',
                iconColor: AppColors.primaryLight,
                trailing: Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (v) => themeProvider.setDarkMode(v),
                  activeColor: AppColors.primary,
                ),
              );
            },
          ),
        ],
      ),
    ).animate(delay: 150.ms).fadeIn();
  }

  Widget _buildInfoSection(BuildContext context, bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: 'APP & PRIVACY INFO', icon: Icons.info_outline_rounded),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.psychology_rounded,
            label: 'Gemini 1.5 Flash AI Engine',
            subtitle: 'Real-time AI emergency summaries',
            iconColor: const Color(0xFF8B5CF6),
          ),
          const Divider(height: 16),
          _SettingsTile(
            icon: Icons.shield_outlined,
            label: 'Privacy & Offline Security',
            subtitle: 'Local Hive storage + Cloud Firestore',
            iconColor: AppColors.success,
          ),
          const Divider(height: 16),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            label: 'About AI Life Vault',
            subtitle: 'Version 1.0.0 • Emergency Medical ID System',
            onTap: () => context.push('/about'),
            iconColor: AppColors.primary,
          ),
        ],
      ),
    ).animate(delay: 200.ms).fadeIn();
  }

  Widget _buildDangerZoneSection(BuildContext context, bool isDark) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, _) {
        if (!profileProvider.hasProfile) return const SizedBox.shrink();
        return GlassCard(
          padding: const EdgeInsets.all(16),
          borderColor: AppColors.emergency.withValues(alpha: 0.4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(title: 'DANGER ZONE', icon: Icons.warning_amber_rounded),
              const SizedBox(height: 12),
              _SettingsTile(
                icon: Icons.delete_forever_rounded,
                label: 'Delete Medical Profile',
                subtitle: 'Permanently remove profile data from local & cloud',
                onTap: () => _confirmDeleteProfile(context, profileProvider),
                iconColor: AppColors.emergency,
              ),
            ],
          ),
        ).animate(delay: 250.ms).fadeIn();
      },
    );
  }

  void _confirmDeleteProfile(BuildContext context, ProfileProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Medical Profile?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        content: const Text(
          'This will permanently delete all your medical data from local storage and cloud. This action cannot be undone.',
          style: TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              await provider.deleteProfile();
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Profile deleted'),
                    backgroundColor: AppColors.emergency,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.emergency,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportProfile(
      BuildContext context, ProfileProvider provider) async {
    final json = provider.exportJson();
    await Share.share(json, subject: 'AI Life Vault - Medical Profile');
  }

  void _showImportDialog(BuildContext context, ProfileProvider provider) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Import Medical Profile',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Paste your profile JSON below:',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              maxLines: 6,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: InputDecoration(
                hintText: '{"id": "...", "fullName": "..."}',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.darkBorder),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await provider.importJson(ctrl.text);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? '✅ Profile imported & synced!' : '❌ Invalid JSON'),
                    backgroundColor:
                        success ? AppColors.success : AppColors.emergency,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 16),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12,
                color: AppColors.textMuted, letterSpacing: 1.0)),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? iconColor;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    this.onTap,
    this.trailing,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primary).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor ?? AppColors.primary, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: onTap == null && trailing == null
                            ? AppColors.textMuted
                            : null,
                      )),
                  Text(subtitle,
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 11)),
                ],
              ),
            ),
            if (trailing != null) trailing!,
            if (trailing == null && onTap != null)
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}
