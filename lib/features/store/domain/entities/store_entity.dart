/// Data toko milik owner, dari `GET /owner/store` / `PUT /owner/store`.
class StoreEntity {
  final String? storeName;
  final String? description;
  final String? address;
  final String? phone;
  final String? logoUrl;

  const StoreEntity({
    this.storeName,
    this.description,
    this.address,
    this.phone,
    this.logoUrl,
  });
}
