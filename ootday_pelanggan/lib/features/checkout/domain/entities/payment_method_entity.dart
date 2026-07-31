/// Metode pembayaran yang dimuat dari GET /payment-methods (data asli dari
/// database, bukan daftar hardcode seperti sebelumnya di
/// payment_method_screen.dart).
class PaymentMethodEntity {
  final int id;
  final String name;

  /// bank_transfer | ewallet | cod
  final String type;

  const PaymentMethodEntity({
    required this.id,
    required this.name,
    required this.type,
  });
}
