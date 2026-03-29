class AdminAnalyticsOverview {
  final int totalUsers;
  final int totalVendors;
  final int totalOrders;
  final double totalRevenue;

  AdminAnalyticsOverview({
    required this.totalUsers,
    required this.totalVendors,
    required this.totalOrders,
    required this.totalRevenue,
  });

  factory AdminAnalyticsOverview.fromJson(Map<String, dynamic> json) {
    return AdminAnalyticsOverview(
      totalUsers: json['totalUsers'] ?? 0,
      totalVendors: json['totalVendors'] ?? 0,
      totalOrders: json['totalOrders'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalUsers': totalUsers,
      'totalVendors': totalVendors,
      'totalOrders': totalOrders,
      'totalRevenue': totalRevenue,
    };
  }
}
