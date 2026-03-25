import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../utils/premium_decorations.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _subtitleFade;

  @override
  void initState() {
    super.initState();
    _mainCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _mainCtrl, curve: Curves.easeOutBack),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _mainCtrl.forward();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final isAuthenticated =
        await ref.read(authStateProvider.notifier).checkAuth();
    if (!mounted) return;

    if (isAuthenticated) {
      final user = ref.read(authStateProvider).user;
      if (user != null) {
        switch (user.role.toString().split('.').last) {
          case 'VENDOR':
            Navigator.of(context).pushReplacementNamed('/vendor');
            break;
          case 'ADMIN':
            Navigator.of(context).pushReplacementNamed('/admin');
            break;
          default:
            Navigator.of(context).pushReplacementNamed('/customer');
        }
        return;
      }
    }
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  void dispose() {
    _mainCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: PremiumGradients.header()),
        child: Stack(
          children: [
            // Decorative circles
            const DecorativeCircle(size: 200, opacity: 0.05, top: -60, right: -40),
            const DecorativeCircle(size: 150, opacity: 0.04, bottom: 80, left: -30),
            const DecorativeCircle(size: 80, opacity: 0.06, top: 120, left: 40),
            const DecorativeCircle(size: 60, opacity: 0.05, bottom: 200, right: 30),
            // Content
            AnimatedBuilder(
              animation: _mainCtrl,
              builder: (context, child) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    // Logo with pulse glow
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: ScaleTransition(
                        scale: _scaleAnim,
                        child: _buildLogo(),
                      ),
                    ),
                    const SizedBox(height: 28),
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: const Text(
                        'Healthy Food Bank',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeTransition(
                      opacity: _subtitleFade,
                      child: Text(
                        'Fresh & Healthy, Delivered to You',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withOpacity(0.8),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    const Spacer(),
                    _buildLoadingDots(),
                    const SizedBox(height: 48),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (context, child) {
        final glowOpacity = Tween<double>(begin: 0.1, end: 0.3)
            .chain(CurveTween(curve: Curves.easeInOut))
            .evaluate(_pulseCtrl);
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(glowOpacity),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.25),
                width: 2.5,
              ),
            ),
            child: const Icon(
              Icons.eco,
              size: 52,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _pulseCtrl,
          builder: (context, child) {
            final delay = index * 0.25;
            final t = ((_pulseCtrl.value + delay) % 1.0);
            final opacity = 0.3 + 0.7 * (t < 0.5 ? t * 2 : 2 - t * 2);
            final translateY = -4.0 * (t < 0.5 ? t * 2 : 2 - t * 2);
            return Transform.translate(
              offset: Offset(0, translateY),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(opacity),
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
