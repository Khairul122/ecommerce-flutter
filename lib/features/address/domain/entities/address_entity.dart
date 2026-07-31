class AddressEntity {
  final String id;
  final String name;
  final String phone;
  final String fullAddress;
  final bool isMain;

  const AddressEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.fullAddress,
    required this.isMain,
  });
}
