import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../domain/entities/shipping_method_entity.dart';
import 'providers/checkout_provider.dart';

/// Ongkir dimuat live per kurir aktif dari RajaOngkir (POST /shipping/cost),
/// dihitung dari toko asal ke district alamat [addressId] yang dipilih di
/// checkout_screen.dart.
class ShippingMethodScreen extends StatefulWidget {
  final String addressId;
  const ShippingMethodScreen({super.key, required this.addressId});

  @override
  State<ShippingMethodScreen> createState() => _ShippingMethodScreenState();
}

class _ShippingMethodScreenState extends State<ShippingMethodScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CheckoutProvider>().loadShippingCost(widget.addressId);
    });
  }

  String _formatRp(num value) {
    return 'Rp ${value.round().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
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
                        onPressed: () => context.read<CheckoutProvider>().loadShippingCost(widget.addressId),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : methods.isEmpty
                  ? const Center(child: Text('Belum ada opsi pengiriman tersedia untuk alamat ini'))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      itemCount: methods.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final ShippingMethodEntity method = methods[index];
                        final label = [method.name, method.service].where((e) => e != null && e.isNotEmpty).join(' - ');

                        return ListTile(
                          onTap: () => Navigator.pop(context, method),
                          leading: const Icon(Icons.local_shipping_outlined, color: maroonColor),
                          title: Text(label, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: method.etd != null ? Text('Estimasi ${method.etd} hari', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)) : null,
                          trailing: Text(_formatRp(method.cost), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: maroonColor)),
                        );
                      },
                    ),
    );
  }
}
