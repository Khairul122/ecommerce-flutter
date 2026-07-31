import 'package:flutter/material.dart';
import 'profil_produk.dart';

class ProfilKategori extends StatelessWidget {
  const ProfilKategori({super.key});

  final Color redMain = const Color(0xFFB40001);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // White background
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: ListView(
          children: [
            _kategoriItem(context, 'Baju Wanita'),
            const SizedBox(height: 12),
            _kategoriItem(context, 'Baju Pria'),
            const SizedBox(height: 12),
            _kategoriItem(context, 'Rok'),
            const SizedBox(height: 12),
            _kategoriItem(context, 'Celana'),
          ],
        ),
      ),
    );
  }

  Widget _kategoriItem(BuildContext context, String title) {
    return GestureDetector(
      onTap: () {
        // Navigasi ke halaman produk dengan kategori yang dipilih
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProfilProduk(kategori: title),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFE0E0E0), // Light grey background
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
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: redMain, // Dark red text
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

