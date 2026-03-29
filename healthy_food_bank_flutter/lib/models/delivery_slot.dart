class DeliverySlot {
  final int? id;
  final DateTime deliveryDate;
  final DateTime cutoffDateTime;
  final bool active;

  DeliverySlot({
    this.id,
    required this.deliveryDate,
    required this.cutoffDateTime,
    this.active = true,
  });

  bool get isOrderAllowed => DateTime.now().isBefore(cutoffDateTime);

  Duration get timeUntilCutoff => cutoffDateTime.difference(DateTime.now());

  factory DeliverySlot.fromJson(Map<String, dynamic> json) {
    return DeliverySlot(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      deliveryDate: _parseDate(json['deliveryDate']),
      cutoffDateTime: _parseDateTime(json['cutoffDateTime']),
      active: json['active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'deliveryDate': _formatDate(deliveryDate),
      'cutoffDateTime': _formatDateTime(cutoffDateTime),
      'active': active,
    };
  }

  DeliverySlot copyWith({
    int? id,
    DateTime? deliveryDate,
    DateTime? cutoffDateTime,
    bool? active,
  }) {
    return DeliverySlot(
      id: id ?? this.id,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      cutoffDateTime: cutoffDateTime ?? this.cutoffDateTime,
      active: active ?? this.active,
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) {
      // Handle "2026-03-30" date-only format
      try {
        final parts = value.split('-');
        if (parts.length == 3) {
          return DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
        }
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)}T${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  @override
  String toString() {
    return 'DeliverySlot(id: $id, deliveryDate: $deliveryDate, cutoff: $cutoffDateTime, active: $active)';
  }
}
