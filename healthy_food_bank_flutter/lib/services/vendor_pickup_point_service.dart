import '../config/api_config.dart';
import '../models/pickup_point.dart';
import 'api_client.dart';
import 'pickup_point_service.dart';

class VendorPickupPointService {
  final ApiClient _api = ApiClient();
  final PickupPointService _pickupPointService = PickupPointService();

  /// Vendor pickup points — API returns flat mappings {id, vendorId, pickupPointId, active}.
  /// Enriches by joining with actual pickup point details.
  Future<List<PickupPoint>> getVendorPickupPoints(String vendorId) async {
    final response = await _api.get(ApiConfig.vendorPickupPoints(vendorId));
    if (!response.success) throw Exception(response.error);
    final mappings = response.data as List;
    if (mappings.isEmpty) return [];

    // Fetch all pickup points for enrichment
    final allPoints = await _pickupPointService.getAllPickupPoints();
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

  /// Active vendor pickup points only
  Future<List<PickupPoint>> getActiveVendorPickupPoints(String vendorId) async {
    final response = await _api.get(ApiConfig.vendorActivePickupPoints(vendorId));
    if (!response.success) throw Exception(response.error);
    final mappings = response.data as List;
    if (mappings.isEmpty) return [];

    // Fetch all pickup points for enrichment
    final allPoints = await _pickupPointService.getAllPickupPoints();
    final pointsById = <int, PickupPoint>{};
    for (final p in allPoints) {
      if (p.id != null) pointsById[p.id!] = p;
    }

    // Join mapping data with actual pickup point details
    final result = <PickupPoint>[];
    for (final m in mappings) {
      final pickupPointId = m['pickupPointId'] as int?;
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
          active: true, // Already filtered by backend
        ));
      }
    }
    return result;
  }

  Future<void> addVendorPickupPoint(String vendorId, Map<String, dynamic> data) async {
    final response = await _api.post(ApiConfig.addVendorPickupPoint(vendorId), body: data);
    if (!response.success) throw Exception(response.error);
  }

  Future<void> toggleVendorPickupPoint(String vendorId, int pickupPointId) async {
    final response = await _api.put(ApiConfig.toggleVendorPickupPoint(vendorId, pickupPointId));
    if (!response.success) throw Exception(response.error);
  }

  Future<void> deleteVendorPickupPoint(String vendorId, int pickupPointId) async {
    final response = await _api.delete(ApiConfig.deleteVendorPickupPoint(vendorId, pickupPointId));
    if (!response.success) throw Exception(response.error);
  }
}
