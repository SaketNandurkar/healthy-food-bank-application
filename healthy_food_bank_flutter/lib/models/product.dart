enum ProductCategory {
  VEGETABLES,
  FRUITS,
  DAIRY,
  GRAINS,
  PROTEINS,
  BEVERAGES,
  ORGANIC,
  OTHERS,
}

class Product {
  final int id;
  final String name;
  final String? description;
  final double price;
  final String? category;
  final String? vendorId;
  final String? vendorName;
  final int stockQuantity;
  final String? imageUrl;
  final double? unitQuantity;
  final String? productUnit;
  final String? deliverySchedule;
  final bool active;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.category,
    this.vendorId,
    this.vendorName,
    required this.stockQuantity,
    this.imageUrl,
    this.unitQuantity,
    this.productUnit,
    this.deliverySchedule,
    this.active = true,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['productId'] ?? json['id'] ?? 0,
      name: json['productName'] ?? json['name'] ?? '',
      description: json['description'] ?? json['productDescription'],
      price: (json['productPrice'] ?? json['price'] ?? 0).toDouble(),
      category: json['category'] ?? json['productCategory'],
      vendorId: json['vendorId']?.toString() ?? json['productAddedBy']?.toString(),
      vendorName: json['vendorName'],
      stockQuantity: (json['productQuantity'] ?? json['stockQuantity'] ?? 0).toInt(),
      imageUrl: json['imageUrl'],
      unitQuantity: (json['unitQuantity'] ?? 1).toDouble(),
      productUnit: json['productUnit'] ?? 'unit',
      deliverySchedule: json['deliverySchedule'],
      active: json['active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productName': name,
      'productPrice': price,
      'productQuantity': stockQuantity,
      'productUnit': productUnit ?? 'unit',
      'unitQuantity': unitQuantity ?? 1,
      if (description != null) 'description': description,
      if (category != null) 'category': category,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (deliverySchedule != null) 'deliverySchedule': deliverySchedule,
    };
  }

  bool get isInStock => stockQuantity > 10;
  bool get isLowStock => stockQuantity > 0 && stockQuantity <= 10;
  bool get isOutOfStock => stockQuantity <= 0;

  String get priceDisplay => '₹${price.toStringAsFixed(price.truncateToDouble() == price ? 0 : 2)}';

  String get unitDisplay {
    final qty = unitQuantity ?? 0;
    final unit = productUnit ?? 'unit';
    if (qty <= 0 || qty == 1) return unit;
    return '${qty.toStringAsFixed(qty.truncateToDouble() == qty ? 0 : 1)} $unit';
  }

  String get pricePerUnit => '$priceDisplay / $unitDisplay';

  String get stockStatus {
    if (isOutOfStock) return 'Out of Stock';
    if (isLowStock) return 'Low Stock';
    return 'In Stock';
  }
}
