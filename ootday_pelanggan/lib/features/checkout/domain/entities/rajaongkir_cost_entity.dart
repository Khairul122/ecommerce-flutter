class ShippingServiceCostEntity {
  final String service;
  final String description;
  final int cost;
  final String etd;

  const ShippingServiceCostEntity({
    required this.service,
    required this.description,
    required this.cost,
    required this.etd,
  });
}

class RajaOngkirCourierEntity {
  final String code;
  final String name;
  final List<ShippingServiceCostEntity> services;

  const RajaOngkirCourierEntity({
    required this.code,
    required this.name,
    required this.services,
  });
}
