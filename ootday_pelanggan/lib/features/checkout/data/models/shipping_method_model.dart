import '../../domain/entities/shipping_method_entity.dart';

class ShippingMethodModel extends ShippingMethodEntity {
  const ShippingMethodModel({
    required super.id,
    required super.name,
    required super.cost,
    super.courier,
    super.service,
    super.description,
    super.etd,
  });

  /// Parse satu opsi dari response POST /shipping/cost (ShippingController::cost).
  factory ShippingMethodModel.fromShippingCostJson(Map<String, dynamic> json) {
    return ShippingMethodModel(
      id: json['shipping_method_id'] is int
          ? json['shipping_method_id'] as int
          : int.tryParse(json['shipping_method_id'].toString()) ?? 0,
      name: json['courier_name']?.toString() ?? '',
      cost: num.tryParse(json['cost']?.toString() ?? '0') ?? 0,
      courier: json['courier']?.toString(),
      service: json['service']?.toString(),
      description: json['description']?.toString(),
      etd: json['etd']?.toString(),
    );
  }
}
