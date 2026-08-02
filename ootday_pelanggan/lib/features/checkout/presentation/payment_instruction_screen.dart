import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/services/api_service.dart';
import 'payment_success_screen.dart';
import '../../order/domain/entities/order_entity.dart';
import '../../order/presentation/providers/order_provider.dart';
import '../domain/entities/payment_method_entity.dart';

/// Layar instruksi pembayaran dengan tampilan Native QRIS langsung di dalam aplikasi
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
  bool _isLoadingQris = false;
  String? _qrisImageUrl;
  String? _qrisError;

  final Color maroonColor = const Color(0xFF5D1A1A);
  final Color tealColor = const Color(0xFF00BFA5);

  String get _orderCode => widget.order.orderCode.isNotEmpty ? widget.order.orderCode : '-';
  String get _paymentMethodName => widget.paymentMethod.name;
  String get _paymentType => widget.paymentMethod.type;

  String _formatRp(num value) {
    return 'Rp ${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  void initState() {
    super.initState();
    if (_paymentType != 'cod') {
      _loadQrisNative();
    }
  }

  Future<void> _loadQrisNative() async {
    if (!mounted) return;
    setState(() {
      _isLoadingQris = true;
      _qrisError = null;
    });

    try {
      final res = await ApiService().post('/orders/${widget.order.id}/qris', {});
      final data = res['data'] as Map<String, dynamic>?;
      String? url = data?['qr_code_url']?.toString();
      final qrString = data?['qr_string']?.toString();

      if ((url == null || url.isEmpty) && qrString != null && qrString.isNotEmpty) {
        url = 'https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=${Uri.encodeComponent(qrString)}';
      }

      if (mounted) {
        setState(() {
          _qrisImageUrl = (url != null && url.isNotEmpty) ? url : null;
          if (_qrisImageUrl == null) {
            _qrisError = data?['message']?.toString() ?? data?['error']?.toString() ?? res['message']?.toString() ?? 'Gagal memuat QRIS';
          }
          _isLoadingQris = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _qrisError = e.toString();
          _isLoadingQris = false;
        });
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

  Widget _buildNativeQrisCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.qr_code_2, color: Color(0xFF00BFA5), size: 30),
              const SizedBox(width: 8),
              Text(
                'QRIS Pembayaran',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Scan menggunakan GoPay, ShopeePay, BCA, Mandiri, BRI, BNI, DANA, OVO, atau m-Banking Anda',
            style: GoogleFonts.outfit(fontSize: 12, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          if (_isLoadingQris)
            const SizedBox(
              height: 220,
              child: Center(child: CircularProgressIndicator(color: Color(0xFF00BFA5))),
            )
          else if (_qrisImageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                _qrisImageUrl!,
                width: 220,
                height: 220,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 220,
                  height: 220,
                  color: Colors.grey[100],
                  child: const Center(child: Text('Gagal memuat gambar QRIS')),
                ),
              ),
            )
          else
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    _qrisError ?? 'QRIS belum tersedia.',
                    style: GoogleFonts.outfit(color: Colors.red, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _loadQrisNative,
                  icon: const Icon(Icons.refresh, size: 18, color: Colors.white),
                  label: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: tealColor),
                ),
              ],
            ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Otomatis terverifikasi real-time',
              style: GoogleFonts.outfit(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              if (!isCod) ...[
                _buildNativeQrisCard(),
                const Divider(height: 1),
              ],
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
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
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
