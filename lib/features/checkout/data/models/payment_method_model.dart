import '../../domain/entities/payment_method_entity.dart';

class PaymentMethodModel extends PaymentMethodEntity {
  const PaymentMethodModel({
    required super.id,
    required super.name,
    required super.type,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
    );
  }
}
