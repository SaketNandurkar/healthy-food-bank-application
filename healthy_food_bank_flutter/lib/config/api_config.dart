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

  // Pickup Points
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

  // Product Service Endpoints
  static const String products = '$productServiceUrl/products';
  static String productById(int id) => '$productServiceUrl/products/$id';
  static String productsByVendor(String vendorId) => '$productServiceUrl/products/vendor/$vendorId';
  static String productsByPickupPoint(int pickupPointId) =>
      '$productServiceUrl/products/by-pickup-point/$pickupPointId';

  // Order Service Endpoints
  static const String orders = '$orderServiceUrl/order';
  static String orderById(int id) => '$orderServiceUrl/order/$id';
  static String customerOrders(int customerId) => '$orderServiceUrl/order/customer/$customerId';
  static String vendorOrders(String vendorId) => '$orderServiceUrl/order/vendor/$vendorId';
  static String vendorIssuedOrders(String vendorId) =>
      '$orderServiceUrl/order/vendor/$vendorId/issued';
  static String vendorScheduledOrders(String vendorId) =>
      '$orderServiceUrl/order/vendor/$vendorId/scheduled';
  static String vendorCancelledOrders(String vendorId) =>
      '$orderServiceUrl/order/vendor/$vendorId/cancelled';
  static String acceptOrder(int id) => '$orderServiceUrl/order/$id/accept';
  static String rejectOrder(int id) => '$orderServiceUrl/order/$id/reject';
  static String updateOrderStatus(int id) => '$orderServiceUrl/order/$id/status';

  // Vendor Codes (Admin)
  static const String vendorCodes = '$userServiceUrl/user/admin/vendor-codes';
  static const String unusedVendorCodes = '$userServiceUrl/user/admin/vendor-codes/unused';
  static const String usedVendorCodes = '$userServiceUrl/user/admin/vendor-codes/used';
}
