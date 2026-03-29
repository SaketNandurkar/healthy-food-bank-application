import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../providers/order_countdown_provider.dart';

/// Premium countdown banner for Friday order cutoff
/// Shows animated countdown timer with urgency-based styling
class OrderCountdownBanner extends ConsumerStatefulWidget {
  const OrderCountdownBanner({super.key});

  @override
  ConsumerState<OrderCountdownBanner> createState() =>
      _OrderCountdownBannerState();
}

class _OrderCountdownBannerState extends ConsumerState<OrderCountdownBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final countdown = ref.watch(orderCountdownProvider);

    // Don't show if not active or still loading
    if (!countdown.isActive || countdown.isLoading) {
      return const SizedBox.shrink();
    }

    // Determine colors based on urgency
    Color bgColor;
    Color borderColor;
    Color iconColor;
    Color textColor;
    Color countdownBgColor;
    IconData icon;

    switch (countdown.urgencyLevel) {
      case 'high': // Less than 2 hours - RED (critical)
        bgColor = Colors.red.shade50;
        borderColor = Colors.red.shade400;
        iconColor = Colors.red.shade700;
        textColor = Colors.red.shade900;
        countdownBgColor = Colors.red.shade100;
        icon = Icons.warning_amber_rounded;
        break;
      case 'medium': // 2-4 hours - ORANGE (warning)
        bgColor = Colors.orange.shade50;
        borderColor = Colors.orange.shade400;
        iconColor = Colors.orange.shade700;
        textColor = Colors.orange.shade900;
        countdownBgColor = Colors.orange.shade100;
        icon = Icons.access_time_rounded;
        break;
      default: // More than 4 hours - GREEN (info)
        bgColor = Colors.green.shade50;
        borderColor = Colors.green.shade400;
        iconColor = Colors.green.shade700;
        textColor = Colors.green.shade900;
        countdownBgColor = Colors.green.shade100;
        icon = Icons.schedule_rounded;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Animated icon
            ScaleTransition(
              scale: countdown.urgencyLevel == 'high'
                  ? _pulseAnimation
                  : const AlwaysStoppedAnimation(1.0),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: countdownBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
            ),
            const SizedBox(width: 16),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    countdown.urgencyLevel == 'high'
                        ? '🚨 Hurry! Order window closing soon'
                        : countdown.deliveryDateFormatted.isNotEmpty
                            ? '📅 Next Delivery: ${countdown.deliveryDateFormatted}'
                            : '⏰ Last chance for weekend orders',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    countdown.cutoffTimeFormatted.isNotEmpty
                        ? 'Order before: ${countdown.cutoffTimeFormatted}'
                        : 'Order before cutoff time',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: textColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

            // Countdown display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: borderColor.withOpacity(0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    countdown.shortFormattedTime,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: iconColor,
                      letterSpacing: 0.5,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  Text(
                    'remaining',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: textColor.withOpacity(0.6),
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact countdown widget for smaller spaces
class CompactCountdownBadge extends ConsumerWidget {
  const CompactCountdownBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countdown = ref.watch(orderCountdownProvider);

    if (!countdown.isActive) {
      return const SizedBox.shrink();
    }

    Color badgeColor;
    switch (countdown.urgencyLevel) {
      case 'high':
        badgeColor = Colors.red.shade600;
        break;
      case 'medium':
        badgeColor = Colors.orange.shade600;
        break;
      default:
        badgeColor = Colors.green.shade600;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.access_time_rounded,
            color: Colors.white,
            size: 14,
          ),
          const SizedBox(width: 5),
          Text(
            countdown.shortFormattedTime,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-width countdown card with detailed information
class DetailedCountdownCard extends ConsumerStatefulWidget {
  const DetailedCountdownCard({super.key});

  @override
  ConsumerState<DetailedCountdownCard> createState() =>
      _DetailedCountdownCardState();
}

class _DetailedCountdownCardState extends ConsumerState<DetailedCountdownCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final countdown = ref.watch(orderCountdownProvider);

    if (!countdown.isActive) {
      return const SizedBox.shrink();
    }

    final isUrgent = countdown.urgencyLevel == 'high';

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isUrgent
              ? [Colors.red.shade400, Colors.red.shade600]
              : [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isUrgent ? Colors.red.shade600 : AppColors.primary)
                .withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Icon(
                  isUrgent
                      ? Icons.warning_amber_rounded
                      : Icons.schedule_rounded,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isUrgent ? 'ORDER CLOSING SOON!' : 'ORDER DEADLINE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withOpacity(0.9),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        countdown.cutoffTimeFormatted.isNotEmpty
                            ? countdown.cutoffTimeFormatted
                            : 'Check delivery schedule',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Countdown display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTimeUnit(
                  countdown.hoursRemaining.toString().padLeft(2, '0'),
                  'HOURS',
                ),
                _buildSeparator(),
                _buildTimeUnit(
                  countdown.minutesRemaining.toString().padLeft(2, '0'),
                  'MINUTES',
                ),
                _buildSeparator(),
                _buildTimeUnit(
                  countdown.secondsRemaining.toString().padLeft(2, '0'),
                  'SECONDS',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Call to action
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isUrgent
                    ? '🚨 Add items to cart NOW to secure delivery!'
                    : countdown.deliveryDateFormatted.isNotEmpty
                        ? '📦 Order today for ${countdown.deliveryDateFormatted} delivery'
                        : '⏰ Order today for fresh delivery',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeUnit(String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
              letterSpacing: 2,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.white.withOpacity(0.8),
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildSeparator() {
    return Text(
      ':',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: Colors.white.withOpacity(0.7),
      ),
    );
  }
}
