import '../../domain/entities/store_entity.dart';

class StoreModel extends StoreEntity {
  const StoreModel({
    super.storeName,
    super.description,
    super.address,
    super.phone,
    super.logoUrl,
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
    );
  }
}
