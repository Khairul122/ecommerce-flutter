import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import '../domain/entities/cart_item_entity.dart';
import '../../checkout/presentation/checkout_screen.dart';
import '../../chat/presentation/chat_list_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCart());
  }

  Future<void> _loadCart() async {
    try {
      await context.read<CartProvider>().loadCart();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat keranjang: $e')),
        );
      }
    }
  }

  Future<void> _toggleSelectAll(bool? value) async {
    final newValue = value ?? false;
    try {
      await context.read<CartProvider>().toggleSelectAll(newValue);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui pilihan: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color maroonColor = Color(0xFFB01D1D);
    const Color bgColor = Color(0xFFF8F3F3);

    final cartProvider = context.watch<CartProvider>();
    final cartItems = cartProvider.items;
    final isLoading = cartProvider.isLoading;
    final hasError = cartProvider.hasError;
    final selectAll = cartProvider.selectAll;
    final totalPrice = cartProvider.totalPrice;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF5D1A1A)),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            TextButton(
              onPressed: () {},
              child: Text(
                'Ubah',
                style: GoogleFonts.outfit(color: const Color(0xFF5D1A1A), fontWeight: FontWeight.w600),
              ),
            ),
            IconButton(
              icon: Image.asset(
                'assets/images/icons msg.png',
                width: 24,
                height: 24,
                color: const Color(0xFF5D1A1A),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatListScreen()),
              ),
            ),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Keranjang Saya',
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF5D1A1A),
                          ),
                        ),
                        Text(
                          '${cartItems.length} items',
                          style: GoogleFonts.outfit(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: cartItems.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: hasError
                                  ? [
                                      Icon(Icons.wifi_off_rounded, size: 80, color: Colors.grey[300]),
                                      const SizedBox(height: 16),
                                      Text('Gagal memuat keranjang', style: GoogleFonts.outfit(fontSize: 16, color: Colors.grey)),
                                      const SizedBox(height: 8),
                                      TextButton(onPressed: _loadCart, child: const Text('Coba Lagi')),
                                    ]
                                  : [
                                      Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[300]),
                                      const SizedBox(height: 16),
                                      Text('Keranjang Anda kosong', style: GoogleFonts.outfit(fontSize: 16, color: Colors.grey)),
                                    ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: cartItems.length,
                            itemBuilder: (context, index) {
                              final item = cartItems[index];
                              return _buildCartItem(item);
                            },
                          ),
                  ),
                ],
              ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Checkbox(
                  value: selectAll,
                  onChanged: _toggleSelectAll,
                  activeColor: maroonColor,
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                Text('semua', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14)),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Total Harga',
                      style: GoogleFonts.outfit(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Rp ${totalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black, height: 1.1),
                    ),
                  ],
                ),
                const SizedBox(width: 15),
                SizedBox(
                  width: 130,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      final selectedItems = cartItems.where((item) => item.selected).toList();
                      if (selectedItems.isNotEmpty) {
                        // CheckoutScreen memuat ulang item terpilih langsung
                        // dari server (GET /cart), jadi cukup navigasi tanpa
                        // membawa data lokal.
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CheckoutScreen(),
                          ),
                        ).then((_) => _loadCart());
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Pilih produk terlebih dahulu!')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: maroonColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: Text(
                      'Checkout',
                      style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCartItem(CartItemEntity item) {
    const Color maroonColor = Color(0xFFB01D1D);

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        children: [
          Checkbox(
            value: item.selected,
            onChanged: (value) async {
              try {
                await context.read<CartProvider>().updateSelection(item.id, value!);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal memperbarui pilihan: $e')),
                  );
                }
              }
            },
            activeColor: maroonColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(width: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: item.image.startsWith('assets/')
                ? Image.asset(
                    item.image,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
                  )
                : Image.network(
                    item.image,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
                  ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                ),
                Text(
                  item.desc,
                  style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey, height: 1.2),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rp ${item.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          _buildQtyBtn(Icons.remove, () async {
                            if (item.quantity > 1) {
                              final newQty = item.quantity - 1;
                              try {
                                await context.read<CartProvider>().updateQuantity(item.id, newQty);
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Gagal memperbarui jumlah: $e')),
                                  );
                                }
                              }
                            }
                          }),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              '${item.quantity}',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
                            ),
                          ),
                          _buildQtyBtn(Icons.add, () async {
                            final newQty = item.quantity + 1;
                            try {
                              await context.read<CartProvider>().updateQuantity(item.id, newQty);
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Gagal memperbarui jumlah: $e')),
                                );
                              }
                            }
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 16, color: Colors.black54),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 90,
      height: 90,
      color: Colors.grey[200],
      child: const Icon(Icons.image, color: Colors.grey, size: 30),
    );
  }
}
