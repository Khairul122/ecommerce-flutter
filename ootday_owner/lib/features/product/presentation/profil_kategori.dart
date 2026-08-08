import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'profil_produk.dart';
import 'providers/product_provider.dart';
import '../domain/entities/category_entity.dart';

class ProfilKategori extends StatefulWidget {
  const ProfilKategori({super.key});

  @override
  State<ProfilKategori> createState() => _ProfilKategoriState();
}

class _ProfilKategoriState extends State<ProfilKategori> {
  final Color redMain = const Color(0xFFB40001);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProductProvider>();
      if (provider.categories.isEmpty) provider.loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();

    return Container(
      color: Colors.white,
      child: provider.isLoadingCategories
          ? const Center(child: CircularProgressIndicator())
          : provider.categories.isEmpty
              ? const Center(child: Text('Belum ada kategori'))
              : Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: ListView.separated(
                    itemCount: provider.categories.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _kategoriItem(context, provider.categories[index]),
                  ),
                ),
    );
  }

  Widget _kategoriItem(BuildContext context, CategoryEntity category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProfilProduk(kategori: category),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                category.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: redMain,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: redMain,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
