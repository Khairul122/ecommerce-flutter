/// Opsi pengiriman. Dimuat live dari POST /shipping/cost (RajaOngkir) per
/// alamat tujuan yang dipilih pelanggan -- bukan daftar base_cost statis lagi.
class ShippingMethodEntity {
  final int id;
  final String name;
  final num cost;
  final String? courier;
  final String? service;
  final String? description;
  final String? etd;

  const ShippingMethodEntity({
    required this.id,
    required this.name,
    required this.cost,
    this.courier,
    this.service,
    this.description,
    this.etd,
  });
}
