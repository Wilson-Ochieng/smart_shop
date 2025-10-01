import 'package:cloud_firestore/cloud_firestore.dart';

class AddressModel {
  final String id;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String additionalPhoneNumber;
  final String additionalInfo;
  final String region;
  final String city;
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.additionalPhoneNumber,
    required this.additionalInfo,
    required this.region,
    required this.city,
    required this.isDefault,
  });

  /// ✅ copyWith method
  AddressModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? additionalPhoneNumber,
    String? additionalInfo,
    String? region,
    String? city,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      additionalPhoneNumber:
          additionalPhoneNumber ?? this.additionalPhoneNumber,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      region: region ?? this.region,
      city: city ?? this.city,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "firstName": firstName,
      "lastName": lastName,
      "phoneNumber": phoneNumber,
      "additionalPhoneNumber": additionalPhoneNumber,
      "additionalInfo": additionalInfo,
      "region": region,
      "city": city,
      "isDefault": isDefault,
    };
  }

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      id: map["id"] ?? "",
      firstName: map["firstName"] ?? "",
      lastName: map["lastName"] ?? "",
      phoneNumber: map["phoneNumber"] ?? "",
      additionalPhoneNumber: map["additionalPhoneNumber"] ?? "",
      additionalInfo: map["additionalInfo"] ?? "",
      region: map["region"] ?? "",
      city: map["city"] ?? "",
      isDefault: map["isDefault"] ?? false,
    );
  }

  factory AddressModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AddressModel.fromMap({...data, "id": doc.id});
  }
}
