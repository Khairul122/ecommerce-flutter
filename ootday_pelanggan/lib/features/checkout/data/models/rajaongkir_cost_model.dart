import '../../domain/entities/rajaongkir_cost_entity.dart';

class ShippingServiceCostModel extends ShippingServiceCostEntity {
  const ShippingServiceCostModel({
    required super.service,
    required super.description,
    required super.cost,
    required super.etd,
  });

  factory ShippingServiceCostModel.fromJson(Map<String, dynamic> json) {
    final costList = json['cost'] as List<dynamic>? ?? [];
    final firstCost = costList.isNotEmpty ? (costList.first as Map<String, dynamic>) : <String, dynamic>{};
    final etdRaw = firstCost['etd']?.toString() ?? '2-3';
    final formattedEtd = etdRaw.contains('HARI') || etdRaw.contains('hari') ? etdRaw : '$etdRaw hari';

    return ShippingServiceCostModel(
      service: json['service']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      cost: int.tryParse(firstCost['value']?.toString() ?? '0') ?? 0,
      etd: formattedEtd,
    );
  }
}

class RajaOngkirCourierModel extends RajaOngkirCourierEntity {
  const RajaOngkirCourierModel({
    required super.code,
    required super.name,
    required super.services,
  });

  factory RajaOngkirCourierModel.fromJson(Map<String, dynamic> json) {
    final costsJson = json['costs'] as List<dynamic>? ?? [];
    final parsedServices = costsJson
        .map((c) => ShippingServiceCostModel.fromJson(c as Map<String, dynamic>))
        .toList();

    return RajaOngkirCourierModel(
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      services: parsedServices,
    );
  }
}
