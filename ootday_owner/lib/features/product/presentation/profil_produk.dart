import 'package:flutter/material.dart';
import 'detail_produk.dart';

class ProfilProduk extends StatelessWidget {
  final String kategori;

  const ProfilProduk({
    super.key,
    required this.kategori,
  });

  final Color redMain = const Color(0xFFB40001);
  final Color darkRed = const Color(0xFF7A0000);

  @override
  Widget build(BuildContext context) {
    // Dummy products based on category
    final products = _getProductsByCategory(kategori);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _header(context),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.72,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return _produkCard(context, product);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 48, bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [darkRed, redMain],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 40,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                kategori,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _produkCard(BuildContext context, Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailProduk(
              name: product['name'] as String,
              price: product['price'] as int,
              image: product['image'] as String,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar Produk
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                    child: Image.asset(
                      product['image'] as String,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFF5F5F5),
                        child: Center(
                          child: Icon(
                            Icons.image,
                            size: 50,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Area Detail Produk
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product['name'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rp ${_formatPrice(product['price'] as int)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: redMain,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getProductsByCategory(String category) {
    // Dummy products - in real app, this would come from API/database
    final allProducts = [
      {'name': 'Luna Cream Blouse', 'price': 150000, 'image': 'assets/produk.1.png', 'category': 'Baju Wanita'},
      {'name': 'Eclipse Jacket', 'price': 200000, 'image': 'assets/produk.2.png', 'category': 'Baju Pria'},
      {'name': 'Floral Pleated Skirt', 'price': 350000, 'image': 'assets/produk.3.png', 'category': 'Rok'},
      {'name': 'Sky Blue Basic Jeans', 'price': 180000, 'image': 'assets/produk.4.png', 'category': 'Celana'},
      {'name': 'Maroon Edge Jacket', 'price': 250000, 'image': 'assets/produk.5.png', 'category': 'Baju Wanita'},
      {'name': 'Classic Khaki Chino Pants', 'price': 220000, 'image': 'assets/produk.6.png', 'category': 'Celana'},
      {'name': 'Brown Blossom', 'price': 180000, 'image': 'assets/produk.7.png', 'category': 'Baju Pria'},
    ];

    return allProducts.where((p) => p['category'] == category).toList();
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}

