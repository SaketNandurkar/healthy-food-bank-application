class TopVendor {
  final String vendorName;
  final int totalOrders;

  TopVendor({
    required this.vendorName,
    required this.totalOrders,
  });

  factory TopVendor.fromJson(Map<String, dynamic> json) {
    return TopVendor(
      vendorName: json['vendorName'] ?? 'Unknown',
      totalOrders: json['totalOrders'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vendorName': vendorName,
      'totalOrders': totalOrders,
    };
  }
}
