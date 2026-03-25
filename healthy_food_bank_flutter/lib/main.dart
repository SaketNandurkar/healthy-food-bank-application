import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/theme.dart';
import 'utils/premium_animations.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/customer/customer_shell.dart';
import 'screens/customer/edit_profile_screen.dart';
import 'screens/customer/my_pickup_points_screen.dart';
import 'screens/customer/notifications_screen.dart';
import 'screens/customer/settings_screen.dart';
import 'screens/customer/help_faq_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const ProviderScope(child: HealthyFoodBankApp()));
}

class HealthyFoodBankApp extends StatelessWidget {
  const HealthyFoodBankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Healthy Food Bank',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case '/':
            page = const SplashScreen();
            break;
          case '/login':
            page = const LoginScreen();
            break;
          case '/register':
            page = const RegisterScreen();
            break;
          case '/customer':
            page = CustomerShell(key: CustomerShell.shellKey);
            break;
          case '/edit-profile':
            page = const EditProfileScreen();
            break;
          case '/my-pickup-points':
            page = const MyPickupPointsScreen();
            break;
          case '/notifications':
            page = const NotificationsScreen();
            break;
          case '/settings':
            page = const SettingsScreen();
            break;
          case '/help-faq':
            page = const HelpFaqScreen();
            break;
          case '/vendor':
            page = const _PlaceholderScreen(
              title: 'Vendor Dashboard',
              subtitle: 'Coming in Phase 2',
            );
            break;
          case '/admin':
            page = const _PlaceholderScreen(
              title: 'Admin Dashboard',
              subtitle: 'Coming in Phase 3',
            );
            break;
          default:
            page = const SplashScreen();
        }
        return PremiumPageRoute(page: page, settings: settings);
      },
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  const _PlaceholderScreen({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.construction, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
              child: const Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }
}
