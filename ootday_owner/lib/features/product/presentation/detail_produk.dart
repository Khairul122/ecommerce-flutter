import 'package:flutter/material.dart';

import '../domain/entities/product_entity.dart';

class DetailProduk extends StatefulWidget {
  final String name;
  final int price;
  final String image;
  final String? description;
  final List<ProductVariantEntity> variants;

  const DetailProduk({
    super.key,
    required this.name,
    required this.price,
    required this.image,
    this.description,
    this.variants = const [],
  });

  @override
  State<DetailProduk> createState() => _DetailProdukState();
}

class _DetailProdukState extends State<DetailProduk> {
  final Color redMain = const Color(0xFFB40001);
  final Color darkRed = const Color(0xFF7A0000);

  late String _displayedImage;
  ProductVariantEntity? _selectedVariant;

  @override
  void initState() {
    super.initState();
    _displayedImage = widget.image;
  }

  void _selectVariant(ProductVariantEntity variant) {
    setState(() {
      _selectedVariant = variant;
      _displayedImage = (variant.imageUrl != null && variant.imageUrl!.isNotEmpty)
          ? variant.imageUrl!
          : widget.image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _header(context),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gambar Produk
                  Container(
                    width: double.infinity,
                    height: 350,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F5F5),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _buildProductImage(_displayedImage, key: ValueKey(_displayedImage)),
                    ),
                  ),
                  // Detail Produk
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Rp ${_formatPrice(widget.price)}',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: redMain,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 24),
                        const Text(
                          'Deskripsi Produk',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          (widget.description == null || widget.description!.trim().isEmpty)
                              ? 'Belum ada deskripsi untuk produk ini.'
                              : widget.description!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                        ),
                        if (widget.variants.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          const Divider(),
                          const SizedBox(height: 24),
                          Text(
                            widget.variants.any((v) => v.imageUrl != null && v.imageUrl!.isNotEmpty)
                                ? 'Varian (ketuk untuk lihat foto)'
                                : 'Varian',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: widget.variants.map((v) {
                              final isSelected = identical(_selectedVariant, v);
                              final hasImage = v.imageUrl != null && v.imageUrl!.isNotEmpty;
                              return GestureDetector(
                                onTap: () => _selectVariant(v),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? redMain.withValues(alpha: 0.1)
                                        : const Color(0xFFF5F5F5),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected ? redMain : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (hasImage)
                                        Icon(Icons.image, size: 14, color: isSelected ? redMain : Colors.grey),
                                      if (hasImage) const SizedBox(width: 4),
                                      Text(
                                        '${v.size} · ${v.color} · Stok ${v.stock}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isSelected ? redMain : Colors.black87,
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
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
            const Text(
              'Detail Produk',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
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

  Widget _buildProductImage(String imageUrl, {Key? key}) {
    final trimmed = imageUrl.trim();
    if (trimmed.isEmpty) return _imagePlaceholder();

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return Image.network(
        trimmed,
        key: key,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _imagePlaceholder(),
      );
    }

    if (trimmed.startsWith('assets/images/')) {
      final fileName = trimmed.replaceFirst('assets/images/', '');
      final serverUrl = 'https://backend-ecommerce.synectra.xyz/storage/seed_images/$fileName';
      return Image.network(
        serverUrl,
        key: key,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) {
          return Image.asset(
            trimmed,
            key: key,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => _imagePlaceholder(),
          );
        },
      );
    }

    if (trimmed.startsWith('assets/')) {
      return Image.asset(
        trimmed,
        key: key,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _imagePlaceholder(),
      );
    }

    final cleanPath = trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;
    final fullUrl = 'https://backend-ecommerce.synectra.xyz/$cleanPath';

    return Image.network(
      fullUrl,
      key: key,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => _imagePlaceholder(),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: Center(
        child: Icon(
          Icons.image,
          size: 100,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }
}

