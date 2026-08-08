class ProvinceEntity {
  final int id;
  final String name;

  const ProvinceEntity({
    required this.id,
    required this.name,
  });
}

class CityEntity {
  final int id;
  final int provinceId;
  final String type;
  final String name;
  final String postalCode;

  const CityEntity({
    required this.id,
    required this.provinceId,
    required this.type,
    required this.name,
    required this.postalCode,
  });

  String get fullCityName => '$type $name';
}
