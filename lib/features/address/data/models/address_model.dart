import '../../domain/entities/address_entity.dart';

class AddressModel extends AddressEntity {
  const AddressModel({
    required super.id,
    required super.name,
    required super.phone,
    required super.fullAddress,
    required super.isMain,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'].toString(),
      name: json['receiver_name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      fullAddress: json['full_address']?.toString() ?? '',
      isMain: json['is_main'] == true || json['is_main'] == 1,
    );
  }
}
