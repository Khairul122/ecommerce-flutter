import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../domain/entities/payment_method_entity.dart';
import 'providers/checkout_provider.dart';

/// Perbaikan audit: layar ini sebelumnya menampilkan daftar metode
/// pembayaran hardcode (nama bank/e-wallet ditulis langsung di kode).
/// Sekarang memuat daftar asli dari GET /payment-methods lewat
/// CheckoutProvider.
class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  PaymentMethodEntity? _selected;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<CheckoutProvider>();
      await provider.loadPaymentMethods();
      if (mounted && provider.paymentMethods.isNotEmpty) {
        setState(() => _selected = provider.paymentMethods.first);
      }
    });
  }

  IconData _iconForType(String? type) {
    switch (type) {
      case 'ewallet':
        return Icons.account_balance_wallet_outlined;
      case 'bank_transfer':
        return Icons.account_balance;
      case 'cod':
        return Icons.handshake_outlined;
      default:
        return Icons.payment;
    }
  }

  String _sectionTitleForType(String? type) {
    switch (type) {
      case 'ewallet':
        return 'E-Wallet';
      case 'bank_transfer':
        return 'Transfer Bank';
      case 'cod':
        return 'Bayar di Tempat';
      default:
        return 'Lainnya';
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color maroonColor = Color(0xFF5D1A1A);
    const Color lightBg = Color(0xFFF3F0F0);

    final checkoutProvider = context.watch<CheckoutProvider>();
    final methods = checkoutProvider.paymentMethods;

    final Map<String, List<PaymentMethodEntity>> grouped = {};
    for (final m in methods) {
      grouped.putIfAbsent(m.type, () => []).add(m);
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: lightBg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: maroonColor),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Metode Pembayaran',
            style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        body: checkoutProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : checkoutProvider.error != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Text(checkoutProvider.error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () => context.read<CheckoutProvider>().loadPaymentMethods(),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  )
                : methods.isEmpty
                    ? const Center(child: Text('Belum ada metode pembayaran tersedia'))
                    : Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: grouped.entries.map((entry) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildSectionHeader(_sectionTitleForType(entry.key), _iconForType(entry.key)),
                                      ...entry.value.map((m) => _buildPaymentItem(m)),
                                      const SizedBox(height: 10),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: ElevatedButton(
                              onPressed: _selected == null ? null : () => Navigator.pop(context, _selected),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: maroonColor,
                                minimumSize: const Size(double.infinity, 55),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(
                                'KONFIRMASI',
                                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: Colors.grey[400], shape: BoxShape.circle),
            child: Icon(icon, color: Colors.black, size: 20),
          ),
          const SizedBox(width: 15),
          Text(title, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPaymentItem(PaymentMethodEntity method) {
    final bool isSelected = _selected != null && _selected!.id == method.id;

    return GestureDetector(
      onTap: () => setState(() => _selected = method),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 1),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
          border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 0.5)),
        ),
        child: Row(
          children: [
            Icon(_iconForType(method.type), color: Colors.black87),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                method.name,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.black : Colors.black87,
                ),
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.arrow_forward_ios,
              size: 16,
              color: isSelected ? const Color(0xFF5D1A1A) : Colors.black26,
            ),
          ],
        ),
      ),
    );
  }
}
