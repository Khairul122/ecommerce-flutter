import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../domain/entities/shipping_method_entity.dart';
import 'providers/checkout_provider.dart';

class ShippingMethodScreen extends StatefulWidget {
  final int? destinationCityId;
  final int? totalWeightGram;

  const ShippingMethodScreen({
    super.key,
    this.destinationCityId,
    this.totalWeightGram,
  });

  @override
  State<ShippingMethodScreen> createState() => _ShippingMethodScreenState();
}

class _ShippingMethodScreenState extends State<ShippingMethodScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CheckoutProvider>();
      if (widget.destinationCityId != null && widget.totalWeightGram != null) {
        provider.loadRajaOngkirOptions(
          destinationCityId: widget.destinationCityId!,
          totalWeightGram: widget.totalWeightGram!,
        );
      } else {
        provider.loadShippingMethods();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color maroonColor = Color(0xFF5D1A1A);

    final checkoutProvider = context.watch<CheckoutProvider>();
    final isRajaOngkirMode = widget.destinationCityId != null;
    final rajaOngkirCouriers = checkoutProvider.rajaOngkirOptions;
    final staticMethods = checkoutProvider.shippingMethods;

    final isLoading = isRajaOngkirMode ? checkoutProvider.isLoadingRajaOngkir : checkoutProvider.isLoading;

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
          'Pilih Ekspedisi & Layanan (RajaOngkir)',
          style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: maroonColor),
                  SizedBox(height: 10),
                  Text('Menghitung ongkir via RajaOngkir...'),
                ],
              ),
            )
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
                        onPressed: () {
                          if (isRajaOngkirMode) {
                            checkoutProvider.loadRajaOngkirOptions(
                              destinationCityId: widget.destinationCityId!,
                              totalWeightGram: widget.totalWeightGram!,
                            );
                          } else {
                            checkoutProvider.loadShippingMethods();
                          }
                        },
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : isRajaOngkirMode
                  ? rajaOngkirCouriers.isEmpty
                      ? const Center(child: Text('Tidak ada opsi pengiriman RajaOngkir tersedia'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: rajaOngkirCouriers.length,
                          itemBuilder: (context, cIndex) {
                            final courier = rajaOngkirCouriers[cIndex];
                            if (courier.services.isEmpty) return const SizedBox.shrink();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.local_shipping, color: maroonColor, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        courier.name,
                                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15, color: maroonColor),
                                      ),
                                    ],
                                  ),
                                ),
                                ...courier.services.map((svc) {
                                  final priceStr = 'Rp ${svc.cost.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    elevation: 1,
                                    child: ListTile(
                                      onTap: () {
                                        checkoutProvider.selectRajaOngkirOption(courier.code, svc);
                                        Navigator.pop(context, {
                                          'courier': courier.code.toUpperCase(),
                                          'service': svc.service,
                                          'cost': svc.cost,
                                          'etd': svc.etd,
                                          'service_object': svc,
                                        });
                                      },
                                      title: Text('${svc.service} - ${svc.description}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                                      subtitle: Text('Estimasi ${svc.etd}', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade600)),
                                      trailing: Text(priceStr, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: maroonColor, fontSize: 14)),
                                    ),
                                  );
                                }),
                                const SizedBox(height: 10),
                              ],
                            );
                          },
                        )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      itemCount: staticMethods.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final ShippingMethodEntity method = staticMethods[index];
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
