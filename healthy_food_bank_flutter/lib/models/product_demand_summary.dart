/// Model for aggregated product demand summary
/// Used to show total quantity needed per product for vendor inventory planning
class ProductDemandSummary {
  final String productName;
  final int? productId;
  final int totalQuantity;
  final String? unit;

  ProductDemandSummary({
    required this.productName,
    this.productId,
    required this.totalQuantity,
    this.unit,
  });

  factory ProductDemandSummary.fromJson(Map<String, dynamic> json) {
    return ProductDemandSummary(
      productName: json['productName'] as String,
      productId: json['productId'] as int?,
      totalQuantity: json['totalQuantity'] as int,
      unit: json['unit'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productName': productName,
      'productId': productId,
      'totalQuantity': totalQuantity,
      'unit': unit,
    };
  }

  @override
  String toString() {
    return 'ProductDemandSummary(productName: $productName, totalQuantity: $totalQuantity, unit: $unit)';
  }
}

/// Response model for vendor order summary
class VendorOrderSummaryResponse {
  final List<ProductDemandSummary> products;
  final int totalOrders;
  final int totalProducts;

  VendorOrderSummaryResponse({
    required this.products,
    required this.totalOrders,
    required this.totalProducts,
  });

  factory VendorOrderSummaryResponse.fromJson(Map<String, dynamic> json) {
    return VendorOrderSummaryResponse(
      products: (json['products'] as List<dynamic>)
          .map((item) => ProductDemandSummary.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalOrders: json['totalOrders'] as int,
      totalProducts: json['totalProducts'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'products': products.map((p) => p.toJson()).toList(),
      'totalOrders': totalOrders,
      'totalProducts': totalProducts,
    };
  }

  @override
  String toString() {
    return 'VendorOrderSummaryResponse(totalProducts: $totalProducts, totalOrders: $totalOrders)';
  }
}
