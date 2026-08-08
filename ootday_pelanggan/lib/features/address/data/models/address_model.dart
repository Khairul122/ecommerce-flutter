import '../../domain/entities/address_entity.dart';

class AddressModel extends AddressEntity {
  const AddressModel({
    required super.id,
    required super.name,
    required super.phone,
    super.provinceId,
    super.provinceName,
    super.cityId,
    super.cityName,
    required super.fullAddress,
    required super.isMain,
    super.districtId,
    super.districtName,
    super.postalCode,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'].toString(),
      name: json['receiver_name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      provinceId: json['province_id'] != null ? int.tryParse(json['province_id'].toString()) : null,
      provinceName: json['province_name']?.toString(),
      cityId: json['city_id'] != null ? int.tryParse(json['city_id'].toString()) : null,
      cityName: json['city_name']?.toString(),
      fullAddress: json['full_address']?.toString() ?? '',
      isMain: json['is_main'] == true || json['is_main'] == 1,
      districtId: json['district_id'] == null ? null : int.tryParse(json['district_id'].toString()),
      districtName: json['district_name']?.toString(),
      postalCode: json['postal_code']?.toString(),
    );
  }
}
