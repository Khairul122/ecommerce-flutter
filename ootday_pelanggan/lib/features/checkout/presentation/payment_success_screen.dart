import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../home/presentation/home_screen.dart';
import '../../order/domain/entities/order_entity.dart';
import '../../order/presentation/my_orders_screen.dart';

/// Sebelumnya layar ini adalah kode mati (tidak pernah dinavigasi ke sini
/// sama sekali). Sekarang dipakai sebagai layar akhir setelah pelanggan
/// menekan "Saya Sudah Bayar" di payment_instruction_screen.dart. Salinan
/// teks sengaja tidak lagi mengklaim "pembayaran berhasil" karena verifikasi
/// pembayaran belum otomatis -- baru menunggu toko memeriksa dan menyetujui.
class PaymentSuccessScreen extends StatelessWidget {
  final OrderEntity? order;
  const PaymentSuccessScreen({super.key, this.order});

  @override
  Widget build(BuildContext context) {
    const Color maroonColor = Color(0xFF5D1A1A);
    final String orderCode = order?.orderCode ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/pymt_done.png',
                width: 150,
                height: 150,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.hourglass_top_rounded, size: 100, color: maroonColor),
              ),
              const SizedBox(height: 20),
              Text(
                'Konfirmasi Pembayaran Terkirim',
                style: GoogleFonts.outfit(
                  color: maroonColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                orderCode.isNotEmpty
                    ? 'Pesanan $orderCode akan diproses setelah toko memverifikasi pembayaran Anda.'
                    : 'Pesanan akan diproses setelah toko memverifikasi pembayaran Anda.',
                style: GoogleFonts.outfit(
                  color: maroonColor.withOpacity(0.8),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 80),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: maroonColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  'Kembali ke Beranda',
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 15),
              OutlinedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MyOrdersScreen(initialTabIndex: 0)), // Tab "Belum Bayar"
                    (route) => false,
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: maroonColor),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  'Lihat Pesanan',
                  style: GoogleFonts.outfit(color: maroonColor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
