import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../../screens/splash_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/dashboard_screen.dart';
import '../../screens/profile/create_edit_profile_screen.dart';
import '../../screens/ai_summary_screen.dart';
import '../../screens/qr_screen.dart';
import '../../screens/emergency_preview_screen.dart';
import '../../screens/settings_screen.dart';
import '../../screens/about_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String createProfile = '/create-profile';
  static const String editProfile = '/edit-profile';
  static const String aiSummary = '/ai-summary';
  static const String qrCode = '/qr-code';
  static const String emergency = '/emergency';
  static const String settings = '/settings';
  static const String about = '/about';

  static String get initialLocation {
    if (kIsWeb) {
      final path = Uri.base.path;

      // IMPORTANT:
      // If someone opens an emergency QR URL directly,
      // NEVER send them through Splash/Login.
      if (path.startsWith('/emergency/')) {
        return path;
      }
    }

    return splash;
  }

  static final GoRouter router = GoRouter(
    initialLocation: initialLocation,

    routes: [
      GoRoute(
        path: splash,
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(
        path: login,
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),

      GoRoute(
        path: createProfile,
        builder: (context, state) =>
            const CreateEditProfileScreen(isEditing: false),
      ),

      GoRoute(
        path: editProfile,
        builder: (context, state) =>
            const CreateEditProfileScreen(isEditing: true),
      ),

      GoRoute(
        path: aiSummary,
        builder: (context, state) => const AiSummaryScreen(),
      ),

      GoRoute(
        path: qrCode,
        builder: (context, state) => const QrScreen(),
      ),

      // ============================================================
      // PUBLIC EMERGENCY ROUTE
      // NO LOGIN REQUIRED
      // ============================================================

      GoRoute(
        path: '/emergency/:qrId',
        builder: (context, state) {
          final qrId = state.pathParameters['qrId'];

          if (qrId == null || qrId.isEmpty) {
            return const EmergencyPreviewScreen();
          }

          return EmergencyPreviewScreen(
            qrId: qrId,
          );
        },
      ),

      GoRoute(
        path: emergency,
        builder: (context, state) {
          final qrId = state.uri.queryParameters['qrId'];

          final rawData = state.uri.queryParameters['data'] ??
              (state.extra is String ? state.extra as String : null);

          return EmergencyPreviewScreen(
            qrId: qrId,
            rawData: rawData,
          );
        },
      ),

      GoRoute(
        path: settings,
        builder: (context, state) => const SettingsScreen(),
      ),

      GoRoute(
        path: about,
        builder: (context, state) => const AboutScreen(),
      ),
    ],
  );
}