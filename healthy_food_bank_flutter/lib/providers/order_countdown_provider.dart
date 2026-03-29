import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/order_service.dart';

final orderCountdownProvider =
    StateNotifierProvider<OrderCountdownNotifier, OrderCountdownState>((ref) {
  return OrderCountdownNotifier();
});

class OrderCountdownState {
  final int hoursRemaining;
  final int minutesRemaining;
  final int secondsRemaining;
  final bool isActive; // True if countdown is running (before cutoff)
  final bool isPastCutoff; // True if cutoff has passed
  final DateTime? cutoffTime;
  final DateTime? deliveryDate;
  final bool isLoading;

  const OrderCountdownState({
    this.hoursRemaining = 0,
    this.minutesRemaining = 0,
    this.secondsRemaining = 0,
    this.isActive = false,
    this.isPastCutoff = false,
    this.cutoffTime,
    this.deliveryDate,
    this.isLoading = true,
  });

  int get totalSeconds =>
      (hoursRemaining * 3600) + (minutesRemaining * 60) + secondsRemaining;

  String get formattedTime {
    final h = hoursRemaining.toString().padLeft(2, '0');
    final m = minutesRemaining.toString().padLeft(2, '0');
    final s = secondsRemaining.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String get shortFormattedTime {
    final h = hoursRemaining.toString().padLeft(2, '0');
    final m = minutesRemaining.toString().padLeft(2, '0');
    return '${h}h ${m}m';
  }

  // Urgency level: high (< 2 hours), medium (< 4 hours), low (>= 4 hours)
  String get urgencyLevel {
    if (hoursRemaining < 2) return 'high';
    if (hoursRemaining < 4) return 'medium';
    return 'low';
  }

  /// Formatted delivery date string (e.g., "Sunday, Mar 30")
  String get deliveryDateFormatted {
    if (deliveryDate == null) return '';
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final d = deliveryDate!;
    return '${weekdays[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}';
  }

  /// Formatted cutoff time string (e.g., "Friday 8:00 PM")
  String get cutoffTimeFormatted {
    if (cutoffTime == null) return '';
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final d = cutoffTime!;
    final hour = d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour);
    final amPm = d.hour >= 12 ? 'PM' : 'AM';
    final minute = d.minute.toString().padLeft(2, '0');
    return '${weekdays[d.weekday - 1]} $hour:$minute $amPm';
  }

  OrderCountdownState copyWith({
    int? hoursRemaining,
    int? minutesRemaining,
    int? secondsRemaining,
    bool? isActive,
    bool? isPastCutoff,
    DateTime? cutoffTime,
    DateTime? deliveryDate,
    bool? isLoading,
  }) {
    return OrderCountdownState(
      hoursRemaining: hoursRemaining ?? this.hoursRemaining,
      minutesRemaining: minutesRemaining ?? this.minutesRemaining,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      isActive: isActive ?? this.isActive,
      isPastCutoff: isPastCutoff ?? this.isPastCutoff,
      cutoffTime: cutoffTime ?? this.cutoffTime,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class OrderCountdownNotifier extends StateNotifier<OrderCountdownState> {
  Timer? _timer;
  Timer? _refreshTimer;
  final OrderService _orderService = OrderService();

  // Fallback IST offset for legacy logic
  static const _istOffset = Duration(hours: 5, minutes: 30);

  OrderCountdownNotifier() : super(const OrderCountdownState()) {
    _fetchAndStartCountdown();
  }

  /// Fetch active delivery slot from API, then start countdown
  Future<void> _fetchAndStartCountdown() async {
    try {
      final data = await _orderService.getActiveDeliverySlot();
      final bool orderAllowed = data['orderAllowed'] ?? false;

      if (orderAllowed && data['cutoffDateTime'] != null) {
        final cutoff = DateTime.parse(data['cutoffDateTime']);
        DateTime? delivery;
        if (data['deliveryDate'] != null) {
          final parts = data['deliveryDate'].toString().split('-');
          if (parts.length == 3) {
            delivery = DateTime(
              int.parse(parts[0]),
              int.parse(parts[1]),
              int.parse(parts[2]),
            );
          }
        }

        state = state.copyWith(
          cutoffTime: cutoff,
          deliveryDate: delivery,
          isLoading: false,
        );
        _startCountdownTimer();
      } else {
        // No active slot - order window closed
        state = const OrderCountdownState(
          isActive: false,
          isPastCutoff: true,
          isLoading: false,
        );
      }
    } catch (e) {
      // API failed - fall back to legacy Friday 8 PM IST logic
      _startLegacyCountdown();
    }

    // Refresh slot data every 5 minutes
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (mounted) _fetchAndStartCountdown();
    });
  }

  /// Start countdown timer that ticks every second against the cutoff time
  void _startCountdownTimer() {
    _timer?.cancel();
    _updateCountdown();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _updateCountdown();
    });
  }

  void _updateCountdown() {
    final cutoff = state.cutoffTime;
    if (cutoff == null) {
      state = state.copyWith(isActive: false, isPastCutoff: true);
      _timer?.cancel();
      return;
    }

    final now = DateTime.now();
    if (now.isAfter(cutoff)) {
      state = state.copyWith(
        isActive: false,
        isPastCutoff: true,
        hoursRemaining: 0,
        minutesRemaining: 0,
        secondsRemaining: 0,
      );
      _timer?.cancel();
      return;
    }

    final difference = cutoff.difference(now);
    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);
    final seconds = difference.inSeconds.remainder(60);

    state = state.copyWith(
      hoursRemaining: hours,
      minutesRemaining: minutes,
      secondsRemaining: seconds,
      isActive: true,
      isPastCutoff: false,
      isLoading: false,
    );
  }

  /// Legacy fallback: Friday 8 PM IST countdown
  void _startLegacyCountdown() {
    final now = DateTime.now().toUtc().add(_istOffset);

    if (now.weekday != DateTime.friday) {
      state = OrderCountdownState(
        isActive: false,
        isPastCutoff: now.weekday == DateTime.saturday || now.weekday == DateTime.sunday,
        isLoading: false,
      );
      return;
    }

    final cutoff = DateTime.utc(now.year, now.month, now.day, 20, 0, 0);
    if (now.isAfter(cutoff)) {
      state = OrderCountdownState(
        isActive: false,
        isPastCutoff: true,
        cutoffTime: cutoff,
        isLoading: false,
      );
      return;
    }

    state = state.copyWith(
      cutoffTime: cutoff,
      isLoading: false,
    );
    _startCountdownTimer();
  }

  void refresh() {
    _fetchAndStartCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }
}
