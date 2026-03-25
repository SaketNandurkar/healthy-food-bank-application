import 'package:flutter/material.dart';
import '../config/theme.dart';

class PremiumShadows {
  /// Two-layer green-tinted shadow for standard cards.
  static List<BoxShadow> card() => [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.06),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  /// Three-layer deep shadow for elevated surfaces (checkout bars, floating nav).
  static List<BoxShadow> elevated() => [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.08),
          blurRadius: 30,
          offset: const Offset(0, 12),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  /// Lightweight shadow for subtle cards.
  static List<BoxShadow> subtle() => [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.04),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.02),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  /// Colored glow shadow for status badges.
  static List<BoxShadow> glow(Color color) => [
        BoxShadow(
          color: color.withOpacity(0.25),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
}

class PremiumGradients {
  /// Rich 3-color header gradient.
  static LinearGradient header() => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF5A8A3E),
          AppColors.primary,
          Color(0xFF7DAD5A),
        ],
      );

  /// Subtle card gradient for selected/active states.
  static LinearGradient cardActive() => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primary,
          AppColors.primary.withOpacity(0.85),
        ],
      );

  /// Button gradient.
  static LinearGradient button() => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF5E9142),
          AppColors.primary,
          Color(0xFF4A7C3A),
        ],
      );
}

/// Decorative organic circle for headers.
class DecorativeCircle extends StatelessWidget {
  final double size;
  final double opacity;
  final double? top;
  final double? right;
  final double? bottom;
  final double? left;

  const DecorativeCircle({
    super.key,
    required this.size,
    this.opacity = 0.08,
    this.top,
    this.right,
    this.bottom,
    this.left,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      right: right,
      bottom: bottom,
      left: left,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(opacity),
        ),
      ),
    );
  }
}

/// Premium header container with gradient and decorative circles.
class PremiumHeader extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double bottomRadius;

  const PremiumHeader({
    super.key,
    required this.child,
    this.padding,
    this.bottomRadius = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: PremiumGradients.header(),
        borderRadius: bottomRadius > 0
            ? BorderRadius.only(
                bottomLeft: Radius.circular(bottomRadius),
                bottomRight: Radius.circular(bottomRadius),
              )
            : null,
      ),
      child: Stack(
        children: [
          // Decorative circles
          const DecorativeCircle(size: 120, opacity: 0.06, top: -30, right: -20),
          const DecorativeCircle(size: 80, opacity: 0.04, bottom: -20, left: -15),
          const DecorativeCircle(size: 50, opacity: 0.05, top: 10, left: 60),
          // Content
          Padding(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Premium card decoration (replaces flat white cards with borders).
BoxDecoration premiumCardDecoration({double borderRadius = 16}) {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(borderRadius),
    boxShadow: PremiumShadows.card(),
  );
}
