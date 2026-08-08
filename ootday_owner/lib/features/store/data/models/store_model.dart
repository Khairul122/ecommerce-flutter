import '../../domain/entities/store_entity.dart';

class StoreModel extends StoreEntity {
  const StoreModel({
    super.storeName,
    super.description,
    super.address,
    super.phone,
    super.logoUrl,
    super.districtId,
    super.districtName,
    super.cityName,
    super.provinceName,
    super.postalCode,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      storeName: json['store_name']?.toString(),
      description: json['description']?.toString(),
      address: json['address']?.toString(),
      phone: json['phone']?.toString(),
      logoUrl: (json['logo_url'] as String?)?.isEmpty ?? true
          ? null
          : json['logo_url'] as String,
      districtId: json['district_id'] == null ? null : int.tryParse(json['district_id'].toString()),
      districtName: json['district_name']?.toString(),
      cityName: json['city_name']?.toString(),
      provinceName: json['province_name']?.toString(),
      postalCode: json['postal_code']?.toString(),
    );
  }
}
