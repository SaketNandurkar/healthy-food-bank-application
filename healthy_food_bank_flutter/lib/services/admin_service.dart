import '../config/api_config.dart';
import '../models/user.dart';
import '../models/pickup_point.dart';
import '../models/delivery_slot.dart';
import 'api_client.dart';

class VendorCode {
  final int? id;
  final String code;
  final String? vendorId;
  final bool isActive;
  final bool isUsed;
  final int? usedByUserId;
  final String? usedBy;
  final DateTime? usedAt;
  final DateTime? createdDate;

  VendorCode({
    this.id,
    required this.code,
    this.vendorId,
    this.isActive = true,
    this.isUsed = false,
    this.usedByUserId,
    this.usedBy,
    this.usedAt,
    this.createdDate,
  });

  factory VendorCode.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      try {
        return DateTime.parse(value.toString());
      } catch (e) {
        return null;
      }
    }

    return VendorCode(
      id: json['id'],
      code: json['vendorCode']?.toString() ?? json['code']?.toString() ?? '',
      vendorId: json['vendorId']?.toString(),
      isActive: json['isActive'] ?? json['active'] ?? true,
      isUsed: json['isUsed'] ?? json['used'] ?? false,
      usedByUserId: json['usedBy'],
      usedBy: json['vendorName']?.toString(),
      usedAt: parseDate(json['usedDate'] ?? json['usedAt']),
      createdDate: parseDate(json['createdDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'code': code,
      if (vendorId != null) 'vendorId': vendorId,
      'isActive': isActive,
      'isUsed': isUsed,
      if (usedByUserId != null) 'usedByUserId': usedByUserId,
      if (usedBy != null) 'usedBy': usedBy,
      if (usedAt != null) 'usedAt': usedAt!.toIso8601String(),
      if (createdDate != null) 'createdDate': createdDate!.toIso8601String(),
    };
  }
}

class UserStats {
  final int totalUsers;
  final int customers;
  final int vendors;
  final int admins;
  final int activeUsers;

  UserStats({
    required this.totalUsers,
    required this.customers,
    required this.vendors,
    required this.admins,
    required this.activeUsers,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalUsers: json['totalUsers'] ?? 0,
      customers: json['customers'] ?? 0,
      vendors: json['vendors'] ?? 0,
      admins: json['admins'] ?? 0,
      activeUsers: json['activeUsers'] ?? 0,
    );
  }
}

class AdminService {
  final ApiClient _api = ApiClient();

  // ============ USER MANAGEMENT ============

  Future<List<User>> getAllUsers({String? roleFilter}) async {
    final url = roleFilter != null
        ? '${ApiConfig.adminUsersUrl}?role=$roleFilter'
        : ApiConfig.adminUsersUrl;
    final response = await _api.get(url);
    if (!response.success) throw Exception(response.error);
    return (response.data as List).map((json) => User.fromJson(json)).toList();
  }

  Future<UserStats> getUserStats() async {
    final response = await _api.get(ApiConfig.adminUserStatsUrl);
    if (!response.success) throw Exception(response.error);
    return UserStats.fromJson(response.data);
  }

  Future<User> activateUser(int userId) async {
    final response =
        await _api.put('${ApiConfig.adminUsersUrl}/$userId/activate');
    if (!response.success) throw Exception(response.error);
    return User.fromJson(response.data);
  }

  Future<User> deactivateUser(int userId) async {
    final response =
        await _api.put('${ApiConfig.adminUsersUrl}/$userId/deactivate');
    if (!response.success) throw Exception(response.error);
    return User.fromJson(response.data);
  }

  // ============ VENDOR CODE MANAGEMENT ============

  Future<List<VendorCode>> getVendorCodes({String? filter}) async {
    String url = ApiConfig.adminVendorCodesUrl;

    if (filter == 'unused') {
      url = ApiConfig.unusedVendorCodes;
    } else if (filter == 'used') {
      url = ApiConfig.usedVendorCodes;
    }

    final response = await _api.get(url);
    if (!response.success) throw Exception(response.error);
    return (response.data as List)
        .map((json) => VendorCode.fromJson(json))
        .toList();
  }

  Future<VendorCode> createVendorCode({String? customCode}) async {
    // Generate a unique code if not provided
    final code = customCode != null && customCode.isNotEmpty
        ? customCode.toUpperCase()
        : 'VC${DateTime.now().millisecondsSinceEpoch}';

    // Extract category from code (e.g., "SPICES01" -> "SPICES")
    // or use "GENERAL" if no pattern matches
    String category = 'GENERAL';
    String vendorName = 'General Vendor';

    // Try to extract category from code pattern (letters before numbers)
    final match = RegExp(r'^([A-Z]+)\d*$').firstMatch(code);
    if (match != null) {
      category = match.group(1)!;
      // Capitalize first letter of each word for vendor name
      vendorName = '${category[0]}${category.substring(1).toLowerCase()} Vendor';
    }

    final body = <String, dynamic>{
      'vendorCode': code,
      'vendorId': category,
      'vendorName': vendorName,
      'description': 'Vendor registration code',
      'active': true,
      'used': false,
    };

    final response = await _api.post(ApiConfig.adminVendorCodesUrl, body: body);
    if (!response.success) throw Exception(response.error);
    return VendorCode.fromJson(response.data);
  }

  Future<VendorCode> updateVendorCode(
      int codeId, Map<String, dynamic> updates) async {
    final response = await _api.put(
        '${ApiConfig.adminVendorCodesUrl}/$codeId',
        body: Map<String, dynamic>.from(updates));
    if (!response.success) throw Exception(response.error);
    return VendorCode.fromJson(response.data);
  }

  Future<void> deleteVendorCode(int codeId) async {
    final response =
        await _api.delete('${ApiConfig.adminVendorCodesUrl}/$codeId');
    if (!response.success) throw Exception(response.error);
  }

  // ============ PICKUP POINT MANAGEMENT ============

  Future<List<PickupPoint>> getAllPickupPoints() async {
    final response = await _api.get(ApiConfig.pickupPointsUrl);
    if (!response.success) throw Exception(response.error);
    return (response.data as List)
        .map((json) => PickupPoint.fromJson(json))
        .toList();
  }

  Future<PickupPoint> createPickupPoint(PickupPoint pickupPoint) async {
    final response = await _api.post(ApiConfig.pickupPointsUrl,
        body: pickupPoint.toJson());
    if (!response.success) throw Exception(response.error);
    return PickupPoint.fromJson(response.data);
  }

  Future<PickupPoint> updatePickupPoint(
      int id, PickupPoint pickupPoint) async {
    final response = await _api.put('${ApiConfig.pickupPointsUrl}/$id',
        body: pickupPoint.toJson());
    if (!response.success) throw Exception(response.error);
    return PickupPoint.fromJson(response.data);
  }

  Future<void> deletePickupPoint(int id) async {
    final response = await _api.delete('${ApiConfig.pickupPointsUrl}/$id');
    if (!response.success) throw Exception(response.error);
  }

  Future<PickupPoint> activatePickupPoint(int id) async {
    final response =
        await _api.put('${ApiConfig.pickupPointsUrl}/$id/activate');
    if (!response.success) throw Exception(response.error);
    return PickupPoint.fromJson(response.data);
  }

  Future<PickupPoint> deactivatePickupPoint(int id) async {
    final response =
        await _api.put('${ApiConfig.pickupPointsUrl}/$id/deactivate');
    if (!response.success) throw Exception(response.error);
    return PickupPoint.fromJson(response.data);
  }

  // ============ DELIVERY SLOT MANAGEMENT ============

  Future<List<DeliverySlot>> getDeliverySlots() async {
    final response = await _api.get(ApiConfig.deliverySlots);
    if (!response.success) throw Exception(response.error);
    return (response.data as List)
        .map((json) => DeliverySlot.fromJson(json))
        .toList();
  }

  Future<DeliverySlot> createDeliverySlot(DeliverySlot slot) async {
    final response =
        await _api.post(ApiConfig.deliverySlots, body: slot.toJson());
    if (!response.success) throw Exception(response.error);
    return DeliverySlot.fromJson(response.data);
  }

  Future<DeliverySlot> updateDeliverySlot(int id, DeliverySlot slot) async {
    final response =
        await _api.put(ApiConfig.deliverySlotById(id), body: slot.toJson());
    if (!response.success) throw Exception(response.error);
    return DeliverySlot.fromJson(response.data);
  }

  Future<DeliverySlot> toggleDeliverySlot(int id) async {
    final response = await _api.put(ApiConfig.toggleDeliverySlot(id));
    if (!response.success) throw Exception(response.error);
    return DeliverySlot.fromJson(response.data);
  }

  Future<void> deleteDeliverySlot(int id) async {
    final response = await _api.delete(ApiConfig.deliverySlotById(id));
    if (!response.success) throw Exception(response.error);
  }
}
