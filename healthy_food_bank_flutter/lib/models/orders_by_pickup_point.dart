class OrdersByPickupPoint {
  final String pickupPointName;
  final int totalOrders;

  OrdersByPickupPoint({
    required this.pickupPointName,
    required this.totalOrders,
  });

  factory OrdersByPickupPoint.fromJson(Map<String, dynamic> json) {
    return OrdersByPickupPoint(
      pickupPointName: json['pickupPointName'] ?? 'Unknown',
      totalOrders: json['totalOrders'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pickupPointName': pickupPointName,
      'totalOrders': totalOrders,
    };
  }
}
