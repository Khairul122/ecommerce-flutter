import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/api_service.dart';
import 'payment_success_screen.dart';
import '../../order/domain/entities/order_entity.dart';
import '../../order/presentation/providers/order_provider.dart';
import '../domain/entities/payment_method_entity.dart';

/// Layar instruksi pembayaran dengan dukungan tombol pembayaran QRIS Midtrans
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
  bool _isFetchingSnap = false;
  final Color maroonColor = const Color(0xFF5D1A1A);

  String get _orderCode => widget.order.orderCode.isNotEmpty ? widget.order.orderCode : '-';
  String get _paymentMethodName => widget.paymentMethod.name;
  String get _paymentType => widget.paymentMethod.type;

  String _formatRp(num value) {
    return 'Rp ${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  Future<void> _payWithMidtrans() async {
    if (!mounted) return;
    setState(() => _isFetchingSnap = true);
    String? snapUrl = widget.order.snapRedirectUrl;
    String? serverError;

    if (snapUrl == null || snapUrl.isEmpty) {
      try {
        final res = await ApiService().post('/orders/${widget.order.id}/snap-token', {});
        final data = res['data'] as Map<String, dynamic>?;
        snapUrl = data?['snap_redirect_url']?.toString();
        if (snapUrl == null || snapUrl.isEmpty) {
          serverError = data?['error']?.toString() ?? res['message']?.toString();
        }
      } catch (e) {
        serverError = e.toString();
        print('Error fetching snap token: $e');
      }
    }

    if (mounted) {
      setState(() => _isFetchingSnap = false);
    }

    if (snapUrl == null || snapUrl.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(serverError ?? 'URL pembayaran QRIS Midtrans tidak tersedia.')),
        );
      }
      return;
    }

    final uri = Uri.parse(snapUrl);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuka Midtrans: $e')),
        );
      }
    }
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
                    Icon(isCod ? Icons.handshake_outlined : Icons.qr_code_scanner, size: 40, color: tealColor),
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
                      isCod
                          ? 'Pembayaran dilakukan saat pesanan tiba'
                          : 'Bayar via QRIS Midtrans (GoPay, ShopeePay, All Bank)',
                      style: GoogleFonts.outfit(color: tealColor, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      isCod
                          ? 'Siapkan pembayaran sejumlah ${_formatRp(totalPrice)} saat kurir mengantarkan pesanan Anda.'
                          : 'Tekan tombol "Bayar via QRIS Midtrans" di bawah untuk melakukan Scan QRIS.',
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
                      'Pembayaran via QRIS Midtrans akan otomatis terverifikasi secara real-time. Setelah QRIS berhasil di-scan dan dibayar, status pesanan akan langsung berubah menjadi "diproses".',
                      style: GoogleFonts.outfit(fontSize: 13, color: Colors.black87, height: 1.5),
                    ),
                  ),
                ),
              const SizedBox(height: 30),
              if (!isCod) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton(
                    onPressed: _isFetchingSnap ? null : _payWithMidtrans,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tealColor,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isFetchingSnap
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.qr_code_2, color: Colors.white, size: 26),
                              const SizedBox(width: 10),
                              Text(
                                'Bayar via QRIS Midtrans',
                                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: OutlinedButton(
                  onPressed: _isConfirming ? null : _confirmPayment,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: maroonColor),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isConfirming
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('Konfirmasi Pembayaran Manual', style: GoogleFonts.outfit(color: maroonColor, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
