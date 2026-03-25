import '../config/api_config.dart';
import '../models/pickup_point.dart';
import 'api_client.dart';

class PickupPointService {
  final ApiClient _api = ApiClient();

  Future<List<PickupPoint>> getActivePickupPoints() async {
    final response = await _api.get(ApiConfig.activePickupPoints);
    if (!response.success) throw Exception(response.error);
    return (response.data as List).map((e) => PickupPoint.fromJson(e)).toList();
  }

  Future<List<PickupPoint>> getAllPickupPoints() async {
    final response = await _api.get(ApiConfig.pickupPoints);
    if (!response.success) throw Exception(response.error);
    return (response.data as List).map((e) => PickupPoint.fromJson(e)).toList();
  }

  Future<PickupPoint?> getPickupPointById(int id) async {
    final response = await _api.get(ApiConfig.pickupPointById(id));
    if (!response.success) return null;
    if (response.data == null) return null;
    return PickupPoint.fromJson(response.data);
  }

  /// Customer pickup points — API returns flat mappings {pickupPointId, active}.
  /// Enriches by joining with actual pickup point details.
  Future<List<PickupPoint>> getCustomerPickupPoints(int customerId) async {
    final response = await _api.get(ApiConfig.customerPickupPoints(customerId));
    if (!response.success) throw Exception(response.error);
    final mappings = response.data as List;
    if (mappings.isEmpty) return [];

    // Fetch all pickup points for enrichment
    final allPoints = await getAllPickupPoints();
    final pointsById = <int, PickupPoint>{};
    for (final p in allPoints) {
      if (p.id != null) pointsById[p.id!] = p;
    }

    // Join mapping data with actual pickup point details
    final result = <PickupPoint>[];
    for (final m in mappings) {
      final pickupPointId = m['pickupPointId'] as int?;
      final isActive = m['active'] as bool? ?? false;
      if (pickupPointId != null && pointsById.containsKey(pickupPointId)) {
        final point = pointsById[pickupPointId]!;
        result.add(PickupPoint(
          id: point.id,
          name: point.name,
          address: point.address,
          city: point.city,
          state: point.state,
          zipCode: point.zipCode,
          contactNumber: point.contactNumber,
          active: isActive,
        ));
      }
    }
    return result;
  }

  /// Active pickup point — API returns flat mapping, enriches with details.
  Future<PickupPoint?> getCustomerActivePickupPoint(int customerId) async {
    final response = await _api.get(ApiConfig.customerActivePickupPoint(customerId));
    if (!response.success) return null;
    if (response.data == null) return null;

    final pickupPointId = response.data['pickupPointId'] as int?;
    if (pickupPointId == null) return null;

    return getPickupPointById(pickupPointId);
  }

  Future<void> addCustomerPickupPoint(int customerId, Map<String, dynamic> data) async {
    final response = await _api.post(ApiConfig.customerPickupPoints(customerId), body: data);
    if (!response.success) throw Exception(response.error);
  }

  Future<void> setActivePickupPoint(int customerId, int pickupPointId) async {
    final response = await _api.put(ApiConfig.setActivePickupPoint(customerId, pickupPointId));
    if (!response.success) throw Exception(response.error);
  }

  Future<void> deleteCustomerPickupPoint(int customerId, int pickupPointId) async {
    final response = await _api.delete(ApiConfig.deleteCustomerPickupPoint(customerId, pickupPointId));
    if (!response.success) throw Exception(response.error);
  }
}
