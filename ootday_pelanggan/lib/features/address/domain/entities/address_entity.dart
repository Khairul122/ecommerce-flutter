class AddressEntity {
  final String id;
  final String name;
  final String phone;
  final int? provinceId;
  final String? provinceName;
  final int? cityId;
  final String? cityName;
  final String fullAddress;
  final bool isMain;
  final int? districtId;
  final String? districtName;
  final String? postalCode;

  const AddressEntity({
    required this.id,
    required this.name,
    required this.phone,
    this.provinceId,
    this.provinceName,
    this.cityId,
    this.cityName,
    required this.fullAddress,
    required this.isMain,
    this.districtId,
    this.districtName,
    this.postalCode,
  });

  String get completeAddress {
    final parts = [fullAddress];
    if (cityName != null && cityName!.isNotEmpty) parts.add(cityName!);
    if (provinceName != null && provinceName!.isNotEmpty) parts.add(provinceName!);
    return parts.join(', ');
  }
}
