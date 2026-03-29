enum OrderStatus {
  PENDING,
  PROCESSING,
  DELIVERED,
  CANCELLED,
  ISSUED,
  SCHEDULED,
  READY,
  CANCELLED_BY_VENDOR,
}

class Order {
  final int? id;
  final String orderName;
  final int orderQuantity;
  final String? orderUnit;
  final double orderPrice;
  final DateTime? orderPlacedDate;
  final DateTime? scheduledDate;
  final DateTime? readyDate;
  final DateTime? deliveredDate;
  final DateTime? orderDeliveredDate; // Deprecated: kept for backward compatibility
  final DateTime? statusUpdatedAt; // For polling-based notifications
  final int? customerId;
  final OrderStatus status;
  final int? productId;
  final String? vendorId;
  final String? productName;
  final String? customerName;
  final String? customerPhone;
  final String? customerPickupPoint;

  Order({
    this.id,
    required this.orderName,
    required this.orderQuantity,
    this.orderUnit,
    required this.orderPrice,
    this.orderPlacedDate,
    this.scheduledDate,
    this.readyDate,
    this.deliveredDate,
    this.orderDeliveredDate,
    this.statusUpdatedAt,
    this.customerId,
    this.status = OrderStatus.PENDING,
    this.productId,
    this.vendorId,
    this.productName,
    this.customerName,
    this.customerPhone,
    this.customerPickupPoint,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      orderName: json['orderName'] ?? '',
      orderQuantity: json['orderQuantity'] ?? 0,
      orderUnit: json['orderUnit'],
      orderPrice: (json['orderPrice'] ?? 0).toDouble(),
      orderPlacedDate: json['orderPlacedDate'] != null
          ? DateTime.tryParse(json['orderPlacedDate'].toString())
          : null,
      scheduledDate: json['scheduledDate'] != null
          ? DateTime.tryParse(json['scheduledDate'].toString())
          : null,
      readyDate: json['readyDate'] != null
          ? DateTime.tryParse(json['readyDate'].toString())
          : null,
      deliveredDate: json['deliveredDate'] != null
          ? DateTime.tryParse(json['deliveredDate'].toString())
          : null,
      orderDeliveredDate: json['orderDeliveredDate'] != null
          ? DateTime.tryParse(json['orderDeliveredDate'].toString())
          : null,
      statusUpdatedAt: json['statusUpdatedAt'] != null
          ? DateTime.tryParse(json['statusUpdatedAt'].toString())
          : null,
      customerId: json['customerId'],
      status: _parseStatus(json['orderStatus'] ?? 'PENDING'),
      productId: json['productId'],
      vendorId: json['vendorId']?.toString(),
      productName: json['productName'],
      customerName: json['customerName'],
      customerPhone: json['customerPhone']?.toString(),
      customerPickupPoint: json['customerPickupPoint'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderName': orderName,
      'orderQuantity': orderQuantity,
      if (orderUnit != null) 'orderUnit': orderUnit,
      'orderPrice': orderPrice,
      if (productId != null) 'productId': productId,
      if (vendorId != null) 'vendorId': vendorId,
      if (customerName != null) 'customerName': customerName,
      if (customerPhone != null) 'customerPhone': customerPhone,
      if (customerPickupPoint != null) 'customerPickupPoint': customerPickupPoint,
    };
  }

  bool get isActive =>
      status == OrderStatus.PENDING ||
      status == OrderStatus.PROCESSING ||
      status == OrderStatus.ISSUED ||
      status == OrderStatus.SCHEDULED ||
      status == OrderStatus.READY;

  String get statusDisplay {
    switch (status) {
      case OrderStatus.CANCELLED_BY_VENDOR:
        return 'Cancelled by Vendor';
      default:
        return status.name[0] + status.name.substring(1).toLowerCase();
    }
  }

  static OrderStatus _parseStatus(String status) {
    switch (status.toUpperCase()) {
      case 'PROCESSING':
        return OrderStatus.PROCESSING;
      case 'DELIVERED':
        return OrderStatus.DELIVERED;
      case 'CANCELLED':
        return OrderStatus.CANCELLED;
      case 'ISSUED':
        return OrderStatus.ISSUED;
      case 'SCHEDULED':
        return OrderStatus.SCHEDULED;
      case 'READY':
        return OrderStatus.READY;
      case 'CANCELLED_BY_VENDOR':
        return OrderStatus.CANCELLED_BY_VENDOR;
      default:
        return OrderStatus.PENDING;
    }
  }
}
