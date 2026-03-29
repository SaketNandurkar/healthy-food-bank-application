import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final orderCountdownProvider =
    StateNotifierProvider<OrderCountdownNotifier, OrderCountdownState>((ref) {
  return OrderCountdownNotifier();
});

class OrderCountdownState {
  final int hoursRemaining;
  final int minutesRemaining;
  final int secondsRemaining;
  final bool isActive; // True if countdown is running (Friday before 8 PM)
  final bool isPastCutoff; // True if it's past Friday 8 PM
  final DateTime? cutoffTime;

  const OrderCountdownState({
    this.hoursRemaining = 0,
    this.minutesRemaining = 0,
    this.secondsRemaining = 0,
    this.isActive = false,
    this.isPastCutoff = false,
    this.cutoffTime,
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

  OrderCountdownState copyWith({
    int? hoursRemaining,
    int? minutesRemaining,
    int? secondsRemaining,
    bool? isActive,
    bool? isPastCutoff,
    DateTime? cutoffTime,
  }) {
    return OrderCountdownState(
      hoursRemaining: hoursRemaining ?? this.hoursRemaining,
      minutesRemaining: minutesRemaining ?? this.minutesRemaining,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      isActive: isActive ?? this.isActive,
      isPastCutoff: isPastCutoff ?? this.isPastCutoff,
      cutoffTime: cutoffTime ?? this.cutoffTime,
    );
  }
}

class OrderCountdownNotifier extends StateNotifier<OrderCountdownState> {
  Timer? _timer;
  static const _istOffset = Duration(hours: 5, minutes: 30);

  OrderCountdownNotifier() : super(const OrderCountdownState()) {
    _startCountdown();
  }

  DateTime _getCurrentIST() {
    return DateTime.now().toUtc().add(_istOffset);
  }

  bool _isFriday() {
    final now = _getCurrentIST();
    return now.weekday == DateTime.friday;
  }

  DateTime? _getFridayCutoff() {
    final now = _getCurrentIST();
    if (now.weekday != DateTime.friday) return null;

    // Friday 8 PM (20:00) IST - MUST be in UTC timezone to match 'now'
    final cutoff = DateTime.utc(now.year, now.month, now.day, 20, 0, 0);
    return cutoff;
  }

  void _startCountdown() {
    _updateCountdown(); // Initial update

    // Update every second
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateCountdown();
    });
  }

  void _updateCountdown() {
    final now = _getCurrentIST();
    print('🔥 COUNTDOWN DEBUG:');
    print('   Current IST time: $now');
    print('   Day of week: ${now.weekday} (5 = Friday)');
    print('   Is Friday: ${_isFriday()}');

    if (!_isFriday()) {
      // Not Friday - deactivate countdown
      print('   ❌ NOT FRIDAY - Countdown inactive');
      state = const OrderCountdownState(
        isActive: false,
        isPastCutoff: false,
      );
      return;
    }

    // Use the 'now' already declared above
    final cutoff = _getFridayCutoff();

    print('   Cutoff time: $cutoff');

    if (cutoff == null) {
      print('   ❌ Cutoff is null');
      state = const OrderCountdownState(isActive: false);
      return;
    }

    // Check if past cutoff
    if (now.isAfter(cutoff)) {
      print('   ❌ PAST CUTOFF - Countdown inactive');
      state = OrderCountdownState(
        isActive: false,
        isPastCutoff: true,
        cutoffTime: cutoff,
      );
      _timer?.cancel(); // Stop timer once past cutoff
      return;
    }

    // Calculate remaining time
    final difference = cutoff.difference(now);
    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);
    final seconds = difference.inSeconds.remainder(60);

    print('   ✅ COUNTDOWN ACTIVE!');
    print('   Time remaining: ${hours}h ${minutes}m ${seconds}s');
    print('   Urgency level: ${hours < 2 ? "high" : hours < 4 ? "medium" : "low"}');

    state = OrderCountdownState(
      hoursRemaining: hours,
      minutesRemaining: minutes,
      secondsRemaining: seconds,
      isActive: true,
      isPastCutoff: false,
      cutoffTime: cutoff,
    );
  }

  void refresh() {
    _updateCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
