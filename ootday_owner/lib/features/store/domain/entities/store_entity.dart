/// Data toko milik owner, dari `GET /owner/store` / `PUT /owner/store`.
class StoreEntity {
  final String? storeName;
  final String? description;
  final String? address;
  final String? phone;
  final String? logoUrl;
  final int? districtId;
  final String? districtName;
  final String? cityName;
  final String? provinceName;
  final String? postalCode;

  const StoreEntity({
    this.storeName,
    this.description,
    this.address,
    this.phone,
    this.logoUrl,
    this.districtId,
    this.districtName,
    this.cityName,
    this.provinceName,
    this.postalCode,
  });
}
