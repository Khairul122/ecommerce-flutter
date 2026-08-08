class AddressEntity {
  final String id;
  final String name;
  final String phone;
  final String fullAddress;
  final bool isMain;
  final int? districtId;
  final String? districtName;
  final String? cityName;
  final String? provinceName;
  final String? postalCode;

  const AddressEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.fullAddress,
    required this.isMain,
    this.districtId,
    this.districtName,
    this.cityName,
    this.provinceName,
    this.postalCode,
  });
}
