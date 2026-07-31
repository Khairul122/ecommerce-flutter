import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../cart/presentation/cart_screen.dart';
import '../../home/presentation/home_screen.dart';
import '../../order/presentation/my_orders_screen.dart';
import '../../product/presentation/product_detail_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color maroonColor = Color(0xFF5D1A1A);
    
    final List<Map<String, String>> recommendations = [
      {
        'id': '1',
        'name': 'Blouse Tunik Biru muda Tali Pinggang',
        'price': '94500',
        'image': 'assets/images/kemeja_wanita/1.jpeg',
        'rating': '4.8',
        'sold': '4RB+ terjual'
      },
      {
        'id': '2',
        'name': 'Kemeja Beige Belted Overshirt',
        'price': '91000',
        'image': 'assets/images/kemeja_wanita/2.jpeg',
        'rating': '4.8',
        'sold': '1RB terjual'
      },
      {
        'id': '3',
        'name': 'Set Kemeja Layer Rompi Biru',
        'price': '110500',
        'image': 'assets/images/kemeja_wanita/3.jpeg',
        'rating': '4.6',
        'sold': '700+ terjual'
      },
      {
        'id': '4',
        'name': 'Blouse Putih Aksen Pita Beludru Hitam',
        'price': '96000',
        'image': 'assets/images/kemeja_wanita/4.jpeg',
        'rating': '4.9',
        'sold': '500 terjual'
      },
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // 1. Maroon Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 30),
                decoration: const BoxDecoration(
                  color: maroonColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen())),
                          child: Stack(
                            children: [
                              const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 28),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                  constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                                  child: const Text('3', style: TextStyle(color: maroonColor, fontSize: 8, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.info_outline, color: Colors.white, size: 24),
                        const SizedBox(width: 10),
                        Text(
                          'Hore, Pesananmu Berhasil!',
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        'Tunggu pesananmu terkirim dan bayar setelah pesanan tiba. Cek "Pesanan Saya" untuk lihat detailnya.',
                        style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildHeaderButton('Beranda', () {
                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const HomeScreen()), (route) => false);
                        }),
                        const SizedBox(width: 15),
                        _buildHeaderButton('Pesanan Saya', () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const MyOrdersScreen(initialTabIndex: 1)));
                        }),
                      ],
                    ),
                  ],
                ),
              ),
              
              // 2. Recommendations Grid
              Padding(
                padding: const EdgeInsets.all(20),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: recommendations.length,
                  itemBuilder: (context, index) {
                    final item = recommendations[index];
                    return _buildProductCard(context, item);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderButton(String label, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.white, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      ),
      child: Text(label, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, String> product) {
    String formattedPrice = 'Rp ${int.parse(product['price']!).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.asset(product['image']!, width: double.infinity, fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product['name']!, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 5),
                  Text(formattedPrice, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF5D1A1A))),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 12),
                      const SizedBox(width: 4),
                      Text(product['rating']!, style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey)),
                      const SizedBox(width: 8),
                      Text(product['sold']!, style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
