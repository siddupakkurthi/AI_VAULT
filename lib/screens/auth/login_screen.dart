import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/common_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  // Login controllers
  final _loginEmailCtrl = TextEditingController();
  final _loginPasswordCtrl = TextEditingController();

  // Register controllers
  final _regNameCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPasswordCtrl = TextEditingController();
  final _regConfirmPasswordCtrl = TextEditingController();

  bool _obscureLoginPassword = true;
  bool _obscureRegPassword = true;
  bool _obscureRegConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailCtrl.dispose();
    _loginPasswordCtrl.dispose();
    _regNameCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPasswordCtrl.dispose();
    _regConfirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final profileProvider = context.read<ProfileProvider>();

    final success = await authProvider.signInWithEmail(
      _loginEmailCtrl.text.trim(),
      _loginPasswordCtrl.text.trim(),
    );

    if (mounted) {
      if (success) {
        await profileProvider.loadProfileForUser(authProvider.uid);
        if (mounted) context.go(AppRouter.dashboard);
      } else if (authProvider.errorMessage != null) {
        _showErrorSnackBar(authProvider.errorMessage!);
      }
    }
  }

  Future<void> _handleRegister() async {
    if (!_registerFormKey.currentState!.validate()) return;

    if (_regPasswordCtrl.text != _regConfirmPasswordCtrl.text) {
      _showErrorSnackBar('Passwords do not match');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final profileProvider = context.read<ProfileProvider>();

    final success = await authProvider.registerWithEmail(
      _regEmailCtrl.text.trim(),
      _regPasswordCtrl.text.trim(),
      name: _regNameCtrl.text.trim(),
    );

    if (mounted) {
      if (success) {
        await profileProvider.loadProfileForUser(authProvider.uid);
        if (mounted) context.go(AppRouter.dashboard);
      } else if (authProvider.errorMessage != null) {
        _showErrorSnackBar(authProvider.errorMessage!);
      }
    }
  }

  Future<void> _handleGuestLogin() async {
    final authProvider = context.read<AuthProvider>();
    final profileProvider = context.read<ProfileProvider>();

    final success = await authProvider.signInAnonymously();

    if (mounted) {
      if (success) {
        await profileProvider.loadProfileForUser(authProvider.uid);
        if (mounted) context.go(AppRouter.dashboard);
      } else {
        _showErrorSnackBar(authProvider.errorMessage ?? 'Guest sign-in failed');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.emergency,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();

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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Branding
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      size: 38,
                      color: Colors.white,
                    ),
                  ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.8, 0.8)),

                  const SizedBox(height: 14),

                  ShaderMask(
                    shaderCallback: (bounds) =>
                        AppColors.primaryGradient.createShader(bounds),
                    child: const Text(
                      'AI LIFE VAULT',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                        color: Colors.white,
                      ),
                    ),
                  ).animate(delay: 100.ms).fadeIn(),

                  const SizedBox(height: 4),

                  Text(
                    'Emergency Medical ID System',
                    style: TextStyle(
                      color: isDark ? AppColors.textMuted : Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ).animate(delay: 150.ms).fadeIn(),

                  const SizedBox(height: 24),

                  // Auth Glass Card
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Tab Bar
                        Container(
                          height: 42,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkBg.withValues(alpha: 0.5)
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TabBar(
                            controller: _tabController,
                            indicator: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            labelColor: Colors.white,
                            unselectedLabelColor:
                                isDark ? AppColors.textMuted : Colors.grey.shade700,
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            tabs: const [
                              Tab(text: 'Sign In'),
                              Tab(text: 'Register'),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Animated Dynamic Height Tab Bar View Container
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          height: _tabController.index == 0 ? 210 : 330,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildLoginForm(isDark, authProvider.isLoading),
                              _buildRegisterForm(isDark, authProvider.isLoading),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1),

                  const SizedBox(height: 18),

                  // Divider with "OR"
                  Row(
                    children: [
                      Expanded(
                          child: Divider(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            color: isDark ? AppColors.textMuted : Colors.grey,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                          child: Divider(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder)),
                    ],
                  ).animate(delay: 300.ms).fadeIn(),

                  const SizedBox(height: 16),

                  // Continue as Guest Button
                  OutlinedButton.icon(
                    onPressed: authProvider.isLoading ? null : _handleGuestLogin,
                    icon: const Icon(Icons.person_outline_rounded, size: 18),
                    label: const Text('Continue as Guest'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? Colors.white70 : AppColors.textDark,
                      side: BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ).animate(delay: 350.ms).fadeIn(),

                  const SizedBox(height: 12),

                  Text(
                    '🔒 Your medical data is encrypted & stored securely',
                    style: TextStyle(
                      color: isDark ? AppColors.textMuted : Colors.grey,
                      fontSize: 11,
                    ),
                  ).animate(delay: 400.ms).fadeIn(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(bool isDark, bool isLoading) {
    return Form(
      key: _loginFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: _loginEmailCtrl,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(color: isDark ? Colors.white : AppColors.textDark),
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined, size: 18),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Please enter your email';
              if (!v.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _loginPasswordCtrl,
            obscureText: _obscureLoginPassword,
            style: TextStyle(color: isDark ? Colors.white : AppColors.textDark),
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureLoginPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 18,
                ),
                onPressed: () => setState(
                    () => _obscureLoginPassword = !_obscureLoginPassword),
              ),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Please enter your password';
              if (v.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
          ),
          const SizedBox(height: 20),
          GradientButton(
            label: 'Sign In',
            icon: Icons.login_rounded,
            isLoading: isLoading,
            onPressed: isLoading ? null : _handleLogin,
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm(bool isDark, bool isLoading) {
    return Form(
      key: _registerFormKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextFormField(
              controller: _regNameCtrl,
              keyboardType: TextInputType.name,
              style: TextStyle(color: isDark ? Colors.white : AppColors.textDark),
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_outline_rounded, size: 18),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Please enter your full name';
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _regEmailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: isDark ? Colors.white : AppColors.textDark),
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined, size: 18),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Please enter your email';
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _regPasswordCtrl,
              obscureText: _obscureRegPassword,
              style: TextStyle(color: isDark ? Colors.white : AppColors.textDark),
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureRegPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 18,
                  ),
                  onPressed: () => setState(
                      () => _obscureRegPassword = !_obscureRegPassword),
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Please enter a password';
                if (v.length < 6) return 'Password must be at least 6 characters';
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _regConfirmPasswordCtrl,
              obscureText: _obscureRegConfirmPassword,
              style: TextStyle(color: isDark ? Colors.white : AppColors.textDark),
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureRegConfirmPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 18,
                  ),
                  onPressed: () => setState(() =>
                      _obscureRegConfirmPassword = !_obscureRegConfirmPassword),
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Please confirm your password';
                if (v != _regPasswordCtrl.text) return 'Passwords do not match';
                return null;
              },
            ),
            const SizedBox(height: 16),
            GradientButton(
              label: 'Create Account',
              icon: Icons.person_add_rounded,
              isLoading: isLoading,
              onPressed: isLoading ? null : _handleRegister,
            ),
          ],
        ),
      ),
    );
  }
}
