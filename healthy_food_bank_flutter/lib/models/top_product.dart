class TopProduct {
  final String productName;
  final int totalQuantity;

  TopProduct({
    required this.productName,
    required this.totalQuantity,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    return TopProduct(
      productName: json['productName'] ?? 'Unknown',
      totalQuantity: json['totalQuantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productName': productName,
      'totalQuantity': totalQuantity,
    };
  }
}
