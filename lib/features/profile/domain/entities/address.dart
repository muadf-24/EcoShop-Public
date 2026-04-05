import 'package:equatable/equatable.dart';

class Address extends Equatable {
  final String id;
  final String label; // e.g., Home, Work
  final String fullName;
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final String phone;
  final bool isDefault;

  const Address({
    required this.id,
    required this.label,
    required this.fullName,
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    required this.phone,
    this.isDefault = false,
  });

  Address copyWith({
    String? id,
    String? label,
    String? fullName,
    String? street,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    String? phone,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      label: label ?? this.label,
      fullName: fullName ?? this.fullName,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      phone: phone ?? this.phone,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'fullName': fullName,
      'street': street,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
      'phone': phone,
      'isDefault': isDefault,
    };
  }

  factory Address.fromMap(Map<String, dynamic> map, String documentId) {
    return Address(
      id: documentId,
      label: map['label'] ?? '',
      fullName: map['fullName'] ?? '',
      street: map['street'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      zipCode: map['zipCode'] ?? '',
      country: map['country'] ?? '',
      phone: map['phone'] ?? '',
      isDefault: map['isDefault'] ?? false,
    );
  }

  @override
  List<Object?> get props => [id, label, fullName, street, city, state, zipCode, country, phone, isDefault];
}
