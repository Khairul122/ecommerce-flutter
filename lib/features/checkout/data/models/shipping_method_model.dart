import '../../domain/entities/shipping_method_entity.dart';

class ShippingMethodModel extends ShippingMethodEntity {
  const ShippingMethodModel({
    required super.id,
    required super.name,
    required super.baseCost,
  });

  factory ShippingMethodModel.fromJson(Map<String, dynamic> json) {
    return ShippingMethodModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      baseCost: double.tryParse(json['base_cost']?.toString() ?? '0') ?? 0,
    );
  }
}
