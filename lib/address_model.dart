import 'dart:convert';

class Address {
  final int addressId;
  final int userId;
  final String fullAddress;
  final double latitude;
  final double longitude;
  final String houseFlatNumber;
  final String apartmentSocietyRoad;
  final String addressTag;
  final int isDefault;
  final String receiverName;
  final String receiverPhone;
  final DateTime createdAt;
  final DateTime updatedAt;

  Address({
    required this.addressId,
    required this.userId,
    required this.fullAddress,
    required this.latitude,
    required this.longitude,
    required this.houseFlatNumber,
    required this.apartmentSocietyRoad,
    required this.addressTag,
    required this.isDefault,
    required this.receiverName,
    required this.receiverPhone,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Address.fromMap(Map<String, dynamic> map) {
    double parseDouble(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return Address(
      addressId: map['address_id'],
      userId: map['user_id'],
      fullAddress: map['full_address'],
      latitude: parseDouble(map['latitude']),
      longitude: parseDouble(map['longitude']),
      houseFlatNumber: map['house_flat_number'],
      apartmentSocietyRoad: map['apartment_society_road'],
      addressTag: map['address_tag'],
      isDefault: map['is_default'],
      receiverName: map['receiver_name'],
      receiverPhone: map['receiver_phone'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address_id': addressId,
      'user_id': userId,
      'full_address': fullAddress,
      'latitude': latitude,
      'longitude': longitude,
      'house_flat_number': houseFlatNumber,
      'apartment_society_road': apartmentSocietyRoad,
      'address_tag': addressTag,
      'is_default': isDefault,
      'receiver_name': receiverName,
      'receiver_phone': receiverPhone,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Optional: convert to JSON string
  String toJsonString() => jsonEncode(toJson());

  // Optional: create from JSON string
  factory Address.fromJsonString(String source) =>
      Address.fromMap(jsonDecode(source));
}
