import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'payment_success_screen.dart';
import '../../order/domain/entities/order_entity.dart';
import '../../order/presentation/providers/order_provider.dart';
import '../domain/entities/payment_method_entity.dart';

/// Perbaikan audit penting: layar ini sebelumnya menganggap pembayaran
/// SELALU berhasil begitu pengguna menekan tombol "OK" (dialog sukses
/// instan tanpa verifikasi apa pun, dan menampilkan nomor Virtual Account
/// palsu yang ditulis langsung di kode). Sekarang tombol konfirmasi memanggil
/// POST /orders/{id}/confirm-payment (lewat OrderProvider.confirmPayment,
/// dipakai bersama my_orders_screen.dart/order_details_screen.dart), dan
/// status pesanan menjadi "menunggu_konfirmasi" -- BUKAN langsung lunas,
/// karena belum ada gateway pembayaran sungguhan yang terhubung. Verifikasi
/// akhir tetap dilakukan manual oleh pemilik toko lewat aplikasi owner.
class PaymentInstructionScreen extends StatefulWidget {
  final OrderEntity order;
  final PaymentMethodEntity paymentMethod;
  const PaymentInstructionScreen({super.key, required this.order, required this.paymentMethod});

  @override
  State<PaymentInstructionScreen> createState() => _PaymentInstructionScreenState();
}

class _PaymentInstructionScreenState extends State<PaymentInstructionScreen> {
  bool _isExpanded = true;
  bool _isConfirming = false;
  final Color maroonColor = const Color(0xFF5D1A1A);

  String get _orderCode => widget.order.orderCode.isNotEmpty ? widget.order.orderCode : '-';
  String get _paymentMethodName => widget.paymentMethod.name;
  String get _paymentType => widget.paymentMethod.type;

  String _formatRp(num value) {
    return 'Rp ${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  Future<void> _confirmPayment() async {
    setState(() => _isConfirming = true);
    try {
      final orderId = widget.order.id.toString();
      final updatedOrder = await context.read<OrderProvider>().confirmPayment(orderId);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PaymentSuccessScreen(order: updatedOrder)),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim konfirmasi pembayaran: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isConfirming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color tealColor = Color(0xFF00BFA5);

    final num totalPrice = widget.order.totalPrice;
    final bool isCod = _paymentType == 'cod';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color.fromARGB(255, 166, 15, 15)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Pembayaran',
            style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(isCod ? Icons.handshake_outlined : Icons.account_balance, size: 40, color: tealColor),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        _paymentMethodName,
                        style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('No. Pesanan', style: GoogleFonts.outfit(color: Colors.black54, fontSize: 13)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _orderCode,
                          style: GoogleFonts.outfit(color: maroonColor, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                        ),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: _orderCode));
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Nomor pesanan $_orderCode disalin!')));
                          },
                          child: Text('Salin', style: GoogleFonts.outfit(color: tealColor, fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Pembayaran', style: GoogleFonts.outfit(color: Colors.black54, fontSize: 13)),
                        Text(_formatRp(totalPrice), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCod ? 'Pembayaran dilakukan saat pesanan tiba' : 'Selesaikan pembayaran lalu konfirmasi di aplikasi',
                      style: GoogleFonts.outfit(color: tealColor, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      isCod
                          ? 'Siapkan pembayaran sejumlah ${_formatRp(totalPrice)} saat kurir mengantarkan pesanan Anda.'
                          : 'Selesaikan pembayaran senilai ${_formatRp(totalPrice)} melalui $_paymentMethodName, lalu tekan tombol "Saya Sudah Bayar" di bawah ini.',
                      style: GoogleFonts.outfit(color: Colors.black87, fontSize: 13, height: 1.5),
                    ),
                  ],
                ),
              ),
              Container(height: 10, color: Colors.grey[200]),
              GestureDetector(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                child: Container(
                  color: Colors.transparent,
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Informasi Penting',
                        style: GoogleFonts.outfit(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      Icon(_isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.black54),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),
              if (_isExpanded)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Pesanan akan diproses setelah toko memverifikasi pembayaran Anda. Ini bukan konfirmasi otomatis -- setelah Anda menekan "Saya Sudah Bayar", status pesanan berubah menjadi "menunggu konfirmasi" sampai pemilik toko memeriksa dan menyetujuinya.',
                      style: GoogleFonts.outfit(fontSize: 13, color: Colors.black87, height: 1.5),
                    ),
                  ),
                ),
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: _isConfirming ? null : _confirmPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: maroonColor,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isConfirming
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text('Saya Sudah Bayar', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
