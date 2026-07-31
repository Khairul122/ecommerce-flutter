import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class CancellationDetailsScreen extends StatelessWidget {
  const CancellationDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color maroonColor = Color(0xFF5D1A1A);
    const Color lightBg = Color(0xFFEFEFEF);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: lightBg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: maroonColor),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Rincian Pembatalan',
            style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // 1. Status Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                color: const Color(0xFFF8F3F3), // Warna krem pudar
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pembatalan Berhasil',
                          style: GoogleFonts.outfit(
                            color: maroonColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'pada 11-10-2025 23:00',
                          style: GoogleFonts.outfit(color: Colors.black54, fontSize: 12),
                        ),
                      ],
                    ),
                    const Icon(Icons.check_circle, color: maroonColor, size: 45),
                  ],
                ),
              ),
              
              const SizedBox(height: 10),
              
              // 2. Order Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.storefront_outlined, size: 20, color: Colors.black),
                        const SizedBox(width: 10),
                        Text('Ootday Fashion Store', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    const Divider(height: 25),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset('assets/images/kemeja_wanita/3.jpeg', width: 70, height: 70, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Wide Collar Drawstring Sleeve Blouse',
                                style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text('Putih, M', style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                        ),
                        Text('x1', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Align(
                      alignment: Alignment.centerRight,
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.outfit(color: Colors.black, fontSize: 12),
                          children: [
                            const TextSpan(text: 'Total 1 Produk: '),
                            TextSpan(text: 'Rp95.000', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 10),
              
              // 3. Details Section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Diminta oleh', 'Pembeli'),
                    const SizedBox(height: 15),
                    _buildDetailRow('Diminta pada', '11-10-2025 23:00'),
                    const SizedBox(height: 15),
                    _buildDetailRow('Alasan', 'Alasan lainnya'),
                    const SizedBox(height: 15),
                    _buildDetailRow(
                      'Metode pembayaran', 
                      'DANA', 
                      trailingIcon: Icons.account_balance_wallet,
                      iconColor: Colors.blue,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // 4. Action Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: maroonColor),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Rincian Pesanan',
                    style: GoogleFonts.outfit(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {IconData? trailingIcon, Color? iconColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.outfit(color: Colors.black54, fontSize: 13)),
        Row(
          children: [
            if (trailingIcon != null) ...[
              Icon(trailingIcon, size: 18, color: iconColor),
              const SizedBox(width: 5),
            ],
            Text(value, style: GoogleFonts.outfit(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }
}
