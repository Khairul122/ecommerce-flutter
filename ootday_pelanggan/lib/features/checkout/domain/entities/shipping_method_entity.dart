/// Opsi pengiriman yang dimuat dari GET /shipping-methods (data asli dari
/// database, bukan daftar hardcode seperti sebelumnya di
/// shipping_method_screen.dart).
class ShippingMethodEntity {
  final int id;
  final String name;
  final num baseCost;

  const ShippingMethodEntity({
    required this.id,
    required this.name,
    required this.baseCost,
  });
}
