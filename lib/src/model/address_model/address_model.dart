import 'package:hot_diamond_admin/src/enum/address_type.dart';

class Address  {
  final String id;
  final String name;
  final String phoneNumber;
  final String pincode;
  final String state;
  final String city;
  final String houseNumber;
  final String roadName;
  final String? landmark;
  final AddressType type;
  final bool isDefault;

  const Address({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.pincode,
    required this.state,
    required this.city,
    required this.houseNumber,
    required this.roadName,
    this.landmark,
    this.type = AddressType.home,
    this.isDefault = false,
  });

  factory Address.fromMap(Map<String, dynamic> map, String id) {
    return Address(
      id: id,
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      pincode: map['pincode'] ?? '',
      state: map['state'] ?? '',
      city: map['city'] ?? '',
      houseNumber: map['houseNumber'] ?? '',
      roadName: map['roadName'] ?? '',
      landmark: map['landmark'],
      type: AddressType.values.firstWhere(
        (e) => e.toString() == 'AddressType.${map['type'] ?? 'home'}',
        orElse: () => AddressType.home,
      ),
      isDefault: map['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'pincode': pincode,
      'state': state,
      'city': city,
      'houseNumber': houseNumber,
      'roadName': roadName,
      'landmark': landmark,
      'type': type.toString().split('.').last,
      'isDefault': isDefault,
    };
  }
  Address copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? pincode,
    String? state,
    String? city,
    String? houseNumber,
    String? roadName,
    String? landmark,
    AddressType? type,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      pincode: pincode ?? this.pincode,
      state: state ?? this.state,
      city: city ?? this.city,
      houseNumber: houseNumber ?? this.houseNumber,
      roadName: roadName ?? this.roadName,
      landmark: landmark ?? this.landmark,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
    );
  }


}