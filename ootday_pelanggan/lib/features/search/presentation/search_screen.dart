import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'search_result_screen.dart';
import '../../product/presentation/providers/product_provider.dart';
import '../../product/domain/entities/product_entity.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProducts());
  }

  Future<void> _loadProducts() async {
    try {
      await context.read<ProductProvider>().fetchProducts(perPage: 12);
    } catch (_) {
      // ProductProvider sudah menyimpan pesan error; layar ini cukup
      // menampilkan grid kosong bila gagal, sama seperti perilaku semula.
    }
  }

  String _primaryImageUrl(ProductEntity product) {
    if (product.images.isEmpty) return 'assets/images/Produk_1.png';
    final primary = product.images.firstWhere(
      (img) => img.isPrimary,
      orElse: () => product.images.first,
    );
    return primary.imageUrl;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color maroonColor = Color(0xFF5D1A1A);
    const Color bgColor = Color(0xFFF8F3F3);

    final productProvider = context.watch<ProductProvider>();
    final isLoading = productProvider.isLoading;
    final searchProducts = productProvider.products
        .map((p) => {'name': p.name, 'image': _primaryImageUrl(p)})
        .toList();

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom App Bar
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: maroonColor, size: 24),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Container(
                      height: 45,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.grey.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: maroonColor.withOpacity(0.5), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              textInputAction: TextInputAction.search,
                              onSubmitted: (value) {
                                if (value.isNotEmpty) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SearchResultScreen(searchQuery: value),
                                    ),
                                  );
                                }
                              },
                              style: GoogleFonts.outfit(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search',
                                hintStyle: GoogleFonts.outfit(color: Colors.black12.withOpacity(0.5)),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                          Icon(Icons.photo_camera_outlined, color: maroonColor.withOpacity(0.5), size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Section Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Pencarian Pilihan',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: maroonColor,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Search Results Grid
            Expanded(
              child: isLoading && searchProducts.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 40),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: searchProducts.length,
                      itemBuilder: (context, index) {
                        return _buildSearchCard(searchProducts[index], maroonColor);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchCard(Map<String, String> product, Color maroonColor) {
    final String image = product['image']!;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: maroonColor.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
              child: image.startsWith('http')
                  ? Image.network(
                      image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => Image.asset(
                        'assets/images/Produk_1.png',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    )
                  : Image.asset(
                      image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              product['name']!,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
