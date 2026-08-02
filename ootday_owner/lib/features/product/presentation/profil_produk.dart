import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'detail_produk.dart';
import 'providers/product_provider.dart';
import '../domain/entities/category_entity.dart';
import '../domain/entities/product_entity.dart';

class ProfilProduk extends StatefulWidget {
  final CategoryEntity kategori;

  const ProfilProduk({
    super.key,
    required this.kategori,
  });

  @override
  State<ProfilProduk> createState() => _ProfilProdukState();
}

class _ProfilProdukState extends State<ProfilProduk> {
  final Color redMain = const Color(0xFFB40001);
  final Color darkRed = const Color(0xFF7A0000);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProductProvider>();
      if (provider.products.isEmpty) provider.loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final products = context
        .watch<ProductProvider>()
        .products
        .where((p) => p.categoryId == widget.kategori.id)
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _header(context),
          Expanded(
            child: products.isEmpty
                ? const Center(child: Text('Belum ada produk di kategori ini'))
                : Padding(
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
                        return _produkCard(context, products[index]);
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
                widget.kategori.name,
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

  Widget _produkCard(BuildContext context, ProductEntity product) {
    final image = product.primaryImageUrl;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailProduk(
              name: product.name,
              price: product.price.round(),
              image: image,
              description: product.description,
              variants: product.variants,
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
                    child: image.isEmpty
                        ? _imagePlaceholder()
                        : (image.startsWith('http')
                            ? Image.network(
                                image,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (_, __, ___) => _imagePlaceholder(),
                              )
                            : Image.asset(
                                image,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (_, __, ___) => _imagePlaceholder(),
                              )),
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
                      product.name,
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
                      'Rp ${_formatPrice(product.price.round())}',
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

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: Center(
        child: Icon(
          Icons.image,
          size: 50,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}
