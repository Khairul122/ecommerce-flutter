import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../domain/entities/shipping_method_entity.dart';
import 'providers/checkout_provider.dart';

/// Perbaikan audit: layar ini sebelumnya menampilkan 4 kurir hardcode dengan
/// harga tetap. Sekarang memuat opsi asli dari GET /shipping-methods lewat
/// CheckoutProvider.
class ShippingMethodScreen extends StatefulWidget {
  const ShippingMethodScreen({super.key});

  @override
  State<ShippingMethodScreen> createState() => _ShippingMethodScreenState();
}

class _ShippingMethodScreenState extends State<ShippingMethodScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CheckoutProvider>().loadShippingMethods();
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color maroonColor = Color(0xFF5D1A1A);

    final checkoutProvider = context.watch<CheckoutProvider>();
    final methods = checkoutProvider.shippingMethods;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: maroonColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pilih Opsi Pengiriman',
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
                        onPressed: () => context.read<CheckoutProvider>().loadShippingMethods(),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : methods.isEmpty
                  ? const Center(child: Text('Belum ada opsi pengiriman tersedia'))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      itemCount: methods.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final ShippingMethodEntity method = methods[index];
                        final int price = method.baseCost.round();
                        String priceStr = 'Rp ${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

                        return ListTile(
                          onTap: () => Navigator.pop(context, method),
                          leading: const Icon(Icons.local_shipping_outlined, color: maroonColor),
                          title: Text(method.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                          trailing: Text(priceStr, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: maroonColor)),
                        );
                      },
                    ),
    );
  }
}
