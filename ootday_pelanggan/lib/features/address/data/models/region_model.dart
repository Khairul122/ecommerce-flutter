import '../../domain/entities/region_entity.dart';

class ProvinceModel extends ProvinceEntity {
  const ProvinceModel({required super.id, required super.name});

  factory ProvinceModel.fromJson(Map<String, dynamic> json) {
    return ProvinceModel(
      id: int.parse(json['province_id'].toString()),
      name: json['province']?.toString() ?? '',
    );
  }
}

class CityModel extends CityEntity {
  const CityModel({
    required super.id,
    required super.provinceId,
    required super.type,
    required super.name,
    required super.postalCode,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: int.parse(json['city_id'].toString()),
      provinceId: int.parse(json['province_id'].toString()),
      type: json['type']?.toString() ?? '',
      name: json['city_name']?.toString() ?? '',
      postalCode: json['postal_code']?.toString() ?? '',
    );
  }
}
