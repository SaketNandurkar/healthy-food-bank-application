class PickupPoint {
  final int? id;
  final String name;
  final String address;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? contactNumber;
  final bool active;
  final DateTime? createdDate;

  PickupPoint({
    this.id,
    required this.name,
    required this.address,
    this.city,
    this.state,
    this.zipCode,
    this.contactNumber,
    this.active = true,
    this.createdDate,
  });

  factory PickupPoint.fromJson(Map<String, dynamic> json) {
    return PickupPoint(
      id: json['id'],
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      city: json['city'],
      state: json['state'],
      zipCode: json['zipCode'],
      contactNumber: json['contactNumber']?.toString(),
      active: json['active'] ?? true,
      createdDate: json['createdDate'] != null
          ? DateTime.tryParse(json['createdDate'].toString())
          : null,
    );
  }

  String get fullAddress {
    final parts = [address];
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (zipCode != null && zipCode!.isNotEmpty) parts.add(zipCode!);
    return parts.join(', ');
  }

  String get displayText => '$name - $address${city != null ? ', $city' : ''}';
}
