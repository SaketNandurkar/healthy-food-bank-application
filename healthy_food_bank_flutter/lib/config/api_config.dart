class ApiConfig {
  // For Android emulator use 10.0.2.2, for iOS simulator use localhost
  // For physical device, use your machine's IP address
  // For Chrome/Windows desktop, use localhost
  static const String _baseHost = 'localhost';

  static const String userServiceUrl = 'http://$_baseHost:9090';
  static const String productServiceUrl = 'http://$_baseHost:9091';
  static const String orderServiceUrl = 'http://$_baseHost:9092';

  // User Service Endpoints
  static const String register = '$userServiceUrl/user/new';
  static const String authenticate = '$userServiceUrl/user/authenticate';
  static const String validateVendorCode = '$userServiceUrl/user/validate-vendor-code';
  static String updateProfile(int userId) => '$userServiceUrl/user/profile/$userId';
  static String changePassword(int userId) => '$userServiceUrl/user/password/$userId';

  // Admin - User Management
  static const String adminUsersUrl = '$userServiceUrl/user/admin/users';
  static const String adminUserStatsUrl = '$userServiceUrl/user/admin/users/stats';

  // Pickup Points
  static const String pickupPointsUrl = '$userServiceUrl/pickup-points';
  static const String pickupPoints = '$userServiceUrl/pickup-points';
  static const String activePickupPoints = '$userServiceUrl/pickup-points/active';
  static String pickupPointById(int id) => '$userServiceUrl/pickup-points/$id';

  // Customer Pickup Points
  static String customerPickupPoints(int customerId) =>
      '$userServiceUrl/customer-pickup-points/$customerId';
  static String customerActivePickupPoint(int customerId) =>
      '$userServiceUrl/customer-pickup-points/$customerId/active';
  static String setActivePickupPoint(int customerId, int pickupPointId) =>
      '$userServiceUrl/customer-pickup-points/$customerId/active/$pickupPointId';
  static String deleteCustomerPickupPoint(int customerId, int pickupPointId) =>
      '$userServiceUrl/customer-pickup-points/$customerId/$pickupPointId';

  // Vendor Pickup Points
  static String vendorPickupPoints(String vendorId) =>
      '$userServiceUrl/vendor-pickup-points/$vendorId';
  static String vendorActivePickupPoints(String vendorId) =>
      '$userServiceUrl/vendor-pickup-points/$vendorId/active';
  static String addVendorPickupPoint(String vendorId) =>
      '$userServiceUrl/vendor-pickup-points/$vendorId';
  static String toggleVendorPickupPoint(String vendorId, int pickupPointId) =>
      '$userServiceUrl/vendor-pickup-points/$vendorId/toggle/$pickupPointId';
  static String deleteVendorPickupPoint(String vendorId, int pickupPointId) =>
      '$userServiceUrl/vendor-pickup-points/$vendorId/$pickupPointId';

  // Product Service Endpoints
  static const String products = '$productServiceUrl/products';
  static String productById(int id) => '$productServiceUrl/products/$id';
  static String productsByVendor(String vendorId) => '$productServiceUrl/products/vendor/$vendorId';
  static String productsByUser(int userId) => '$productServiceUrl/products/user/$userId';
  static const String uploadProductImage = '$productServiceUrl/products/upload-image';
  static String productsByPickupPoint(int pickupPointId) =>
      '$productServiceUrl/products/by-pickup-point/$pickupPointId';

  // Order Service Endpoints
  static const String orders = '$orderServiceUrl/order';
  static const String checkOrderTiming = '$orderServiceUrl/order/check-timing';
  static String orderById(int id) => '$orderServiceUrl/order/$id';
  static String customerOrders(int customerId) => '$orderServiceUrl/order/customer/$customerId';
  static String vendorOrders(String vendorId) => '$orderServiceUrl/order/vendor/$vendorId';
  static String vendorIssuedOrders(String vendorId) =>
      '$orderServiceUrl/order/vendor/$vendorId/issued';
  static String vendorScheduledOrders(String vendorId) =>
      '$orderServiceUrl/order/vendor/$vendorId/scheduled';
  static String vendorReadyOrders(String vendorId) =>
      '$orderServiceUrl/order/vendor/$vendorId/ready';
  static String vendorCancelledOrders(String vendorId) =>
      '$orderServiceUrl/order/vendor/$vendorId/cancelled';
  static String vendorOrderSummary(String vendorId) =>
      '$orderServiceUrl/order/vendor/$vendorId/summary';
  static String acceptOrder(int id) => '$orderServiceUrl/order/$id/accept';
  static String rejectOrder(int id) => '$orderServiceUrl/order/$id/reject';
  static String updateOrderStatus(int id) => '$orderServiceUrl/order/$id/status';

  // Admin - Vendor Codes
  static const String adminVendorCodesUrl = '$userServiceUrl/user/admin/vendor-codes';
  static const String vendorCodes = '$userServiceUrl/user/admin/vendor-codes';
  static const String unusedVendorCodes = '$userServiceUrl/user/admin/vendor-codes/unused';
  static const String usedVendorCodes = '$userServiceUrl/user/admin/vendor-codes/used';

  // Admin - Analytics
  static const String analyticsOverview = '$orderServiceUrl/admin/analytics/overview';
  static const String analyticsOrdersByPickupPoint = '$orderServiceUrl/admin/analytics/orders-by-pickup-point';
  static const String analyticsTopProducts = '$orderServiceUrl/admin/analytics/top-products';
  static const String analyticsTopVendors = '$orderServiceUrl/admin/analytics/top-vendors';
}
