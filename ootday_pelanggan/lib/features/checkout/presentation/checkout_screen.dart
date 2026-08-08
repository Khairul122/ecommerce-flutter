import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'payment_instruction_screen.dart';
import 'shipping_method_screen.dart';
import 'payment_method_screen.dart';
import '../../address/presentation/address_screen.dart';
import '../../address/domain/entities/address_entity.dart';
import '../../cart/domain/entities/cart_item_entity.dart';
import '../../cart/presentation/providers/cart_provider.dart';
import '../../address/presentation/providers/address_provider.dart';
import '../domain/entities/payment_method_entity.dart';
import '../domain/entities/shipping_method_entity.dart';
import 'providers/checkout_provider.dart';

/// Perbaikan audit penting di layar ini:
/// - Alamat yang benar-benar dipilih pelanggan sekarang dipakai (sebelumnya
///   selalu hardcode "Vanya | ..." dan hasil AddressScreen dibuang begitu
///   saja).
/// - Opsi pengiriman dimuat live per alamat dari POST /shipping/cost
///   (RajaOngkir), metode pembayaran dari GET /payment-methods -- bukan
///   daftar hardcode di shipping_method_screen.dart/payment_method_screen.dart.
/// - Pesanan dibuat lewat POST /orders, yang memvalidasi stok dan mengambil
///   item dari keranjang yang is_selected=true di server -- keranjang TIDAK
///   dikosongkan dari klien lagi (server yang menghapus item yang sudah
///   dipesan).
/// - Pesanan baru dibuat setelah pelanggan menekan "Buat Pesanan", dan baru
///   dianggap lunas setelah pelanggan konfirmasi bayar DAN toko
///   memverifikasi -- bukan otomatis sukses seperti dialog lama.
///
/// Migrasi Clean Architecture: layar ini sekarang memakai CartProvider,
/// AddressProvider, dan CheckoutProvider (lewat context.read/watch) alih-alih
/// memanggil CartData/AddressData/ApiService/OrderData langsung.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final Color maroonColor = const Color(0xFF5D1A1A);

  bool _isLoading = true;
  String? _loadError;
  bool _isPlacingOrder = false;

  AddressEntity? _selectedAddress;
  ShippingMethodEntity? _selectedShippingMethod;
  PaymentMethodEntity? _selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCheckoutData());
  }

  Future<void> _loadCheckoutData() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final cartProvider = context.read<CartProvider>();
      final addressProvider = context.read<AddressProvider>();
      final checkoutProvider = context.read<CheckoutProvider>();

      await Future.wait([
        cartProvider.loadCart(),
        addressProvider.loadAddresses(),
        checkoutProvider.loadPaymentMethods(),
      ]);

      if (addressProvider.error != null) {
        throw Exception(addressProvider.error);
      }
      if (checkoutProvider.error != null) {
        throw Exception(checkoutProvider.error);
      }

      final addresses = addressProvider.addresses;
      AddressEntity? mainAddress;
      if (addresses.isNotEmpty) {
        for (final a in addresses) {
          if (a.isMain) {
            mainAddress = a;
            break;
          }
        }
        mainAddress ??= addresses.first;
      }

      final paymentList = checkoutProvider.paymentMethods;

      if (mainAddress != null) {
        await checkoutProvider.loadShippingCost(mainAddress.id);
      }
      final shippingList = checkoutProvider.shippingMethods;

      if (mounted) {
        setState(() {
          _selectedAddress = mainAddress;
          _selectedShippingMethod = shippingList.isNotEmpty ? shippingList.first : null;
          _selectedPaymentMethod = paymentList.isNotEmpty ? paymentList.first : null;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadError = 'Gagal memuat data checkout: $e';
          _isLoading = false;
        });
      }
    }
  }

  AddressEntity _addressFromMap(Map<String, dynamic> map) => AddressEntity(
        id: map['id'].toString(),
        name: map['name']?.toString() ?? '',
        phone: map['phone']?.toString() ?? '',
        fullAddress: map['fullAddress']?.toString() ?? '',
        isMain: map['isMain'] == true,
      );

  int _subtotal(List<CartItemEntity> items) {
    return items.fold(0, (sum, item) => sum + item.price * item.quantity);
  }

  int get _shippingCost {
    if (_rajaCost != null) return _rajaCost!;
    if (_selectedShippingMethod == null) return 0;
    return _selectedShippingMethod!.cost.round();
  }

  String get _shippingLabel {
    if (_rajaCourier != null && _rajaService != null) {
      final etd = _rajaEtd != null ? ' (Estimasi $_rajaEtd)' : '';
      return '$_rajaCourier $_rajaService$etd';
    }
    return _selectedShippingMethod?.name ?? 'Pilih opsi pengiriman';
  }

  int _totalPrice(List<CartItemEntity> items) => _subtotal(items) + _shippingCost;

  String _formatRp(num value) {
    return 'Rp ${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  Future<void> _pickAddress() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddressScreen(selectMode: true)),
    );
    if (result != null && mounted) {
      final newAddress = _addressFromMap(Map<String, dynamic>.from(result));
      // Ongkir tergantung district tujuan, jadi opsi pengiriman lama tidak
      // valid lagi begitu alamat berubah -- harus dipilih ulang.
      setState(() {
        _selectedAddress = newAddress;
        _selectedShippingMethod = null;
      });
      try {
        await context.read<CheckoutProvider>().loadShippingCost(newAddress.id);
      } catch (_) {}
    }
  }

  String? _rajaCourier;
  String? _rajaService;
  int? _rajaCost;
  String? _rajaEtd;

  Future<void> _pickShippingMethod() async {
    final items = context.read<CartProvider>().items.where((e) => e.selected).toList();
    final totalWeightGram = items.fold<int>(0, (sum, i) => sum + i.weight * i.quantity);
    final cityId = _selectedAddress?.cityId ?? 153;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShippingMethodScreen(
          destinationCityId: cityId,
          totalWeightGram: totalWeightGram > 0 ? totalWeightGram : 500,
        ),
      ),
    );
    if (result != null && mounted) {
      if (result is Map) {
        setState(() {
          _rajaCourier = result['courier']?.toString();
          _rajaService = result['service']?.toString();
          _rajaCost = result['cost'] as int?;
          _rajaEtd = result['etd']?.toString();
        });
      } else if (result is ShippingMethodEntity) {
        setState(() => _selectedShippingMethod = result);
      }
    }
  }

  Future<void> _pickPaymentMethod() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PaymentMethodScreen()),
    );
    if (result != null && mounted) {
      setState(() => _selectedPaymentMethod = result as PaymentMethodEntity);
    }
  }

  Future<void> _placeOrder() async {
    final items = context.read<CartProvider>().items.where((e) => e.selected).toList();

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada produk yang dipilih untuk dipesan')),
      );
      return;
    }
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih alamat pengiriman terlebih dahulu')),
      );
      return;
    }
    if ((_rajaCost == null && _selectedShippingMethod == null) || _selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih opsi pengiriman dan metode pembayaran terlebih dahulu')),
      );
      return;
    }

    setState(() => _isPlacingOrder = true);
    try {
      final order = await context.read<CheckoutProvider>().createOrder(
            addressId: _selectedAddress!.id,
            shippingMethodId: _selectedShippingMethod?.id,
            paymentMethodId: _selectedPaymentMethod!.id,
            shippingCourier: _rajaCourier,
            shippingService: _rajaService,
            shippingCost: _rajaCost,
            shippingEtd: _rajaEtd,
          );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentInstructionScreen(
            order: order,
            paymentMethod: _selectedPaymentMethod!,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat pesanan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = context.watch<CartProvider>().items.where((e) => e.selected).toList();

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
            icon: const Icon(Icons.arrow_back, color: Color(0xFF5D1A1A)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Checkout',
            style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _loadError != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Text(_loadError!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                        ),
                        const SizedBox(height: 10),
                        TextButton(onPressed: _loadCheckoutData, child: const Text('Coba Lagi')),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Alamat Pengiriman'),
                        GestureDetector(
                          onTap: _pickAddress,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.location_on, color: Color(0xFF5D1A1A), size: 24),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _selectedAddress == null
                                      ? Text(
                                          'Pilih alamat pengiriman',
                                          style: GoogleFonts.outfit(color: Colors.grey, fontSize: 14),
                                        )
                                      : Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${_selectedAddress!.name} | ${_selectedAddress!.phone}',
                                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _selectedAddress!.fullAddress,
                                              style: GoogleFonts.outfit(color: Colors.black54, fontSize: 12),
                                            ),
                                          ],
                                        ),
                                ),
                                const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                        const Divider(height: 40),

                        _buildSectionTitle('Pesanan Anda'),
                        if (items.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text('Tidak ada produk terpilih di keranjang', style: GoogleFonts.outfit(color: Colors.grey)),
                          )
                        else
                          ...items.map((item) => _buildProductItem(item)),
                        const Divider(height: 40),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Opsi Pengiriman', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.black)),
                              GestureDetector(
                                onTap: _pickShippingMethod,
                                child: Text('Lihat Semua', style: GoogleFonts.outfit(color: maroonColor, fontSize: 13, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: _pickShippingMethod,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.local_shipping_outlined, color: Color(0xFF5D1A1A), size: 24),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _shippingLabel,
                                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                ),
                                Text(_formatRp(_shippingCost), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(width: 10),
                                const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                        const Divider(height: 40),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Metode Pembayaran', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.black)),
                              GestureDetector(
                                onTap: _pickPaymentMethod,
                                child: Text('Lihat Semua', style: GoogleFonts.outfit(color: maroonColor, fontSize: 13, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                        ListTile(
                          onTap: _pickPaymentMethod,
                          leading: const Icon(Icons.account_balance_wallet, color: Color(0xFF5D1A1A)),
                          title: Text(
                            _selectedPaymentMethod?.name ?? 'Pilih metode pembayaran',
                            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                        ),
                        const Divider(height: 40),

                        _buildSectionTitle('Ringkasan Pembayaran'),
                        _buildSummaryRow('Subtotal Produk', _formatRp(_subtotal(items))),
                        _buildSummaryRow('Biaya Pengiriman', _formatRp(_shippingCost)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Divider(),
                        ),
                        _buildSummaryRow('Total Pembayaran', _formatRp(_totalPrice(items)), isTotal: true),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
        bottomNavigationBar: (_isLoading || _loadError != null) ? null : _buildBottomAction(items),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.black)),
    );
  }

  Widget _buildProductItem(CartItemEntity item) {
    String priceStr = _formatRp(item.price);
    final String image = item.image;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: image.startsWith('assets/')
                ? Image.asset(image, width: 70, height: 70, fit: BoxFit.cover)
                : Image.network(
                    image,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
                  ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(item.desc, style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(priceStr, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF5D1A1A)), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    Text('x${item.quantity}', style: GoogleFonts.outfit(color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.outfit(fontSize: isTotal ? 16 : 13, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: GoogleFonts.outfit(fontSize: isTotal ? 18 : 13, fontWeight: FontWeight.bold, color: isTotal ? const Color(0xFF5D1A1A) : Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(List<CartItemEntity> items) {
    const Color maroonColor = Color(0xFF5D1A1A);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Pembayaran', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
                  Text(
                    _formatRp(_totalPrice(items)),
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900, color: const Color(0xFF5D1A1A)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _isPlacingOrder ? null : _placeOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: maroonColor,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _isPlacingOrder
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text('Buat Pesanan', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
