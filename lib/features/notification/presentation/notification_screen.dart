import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../chat/presentation/chat_list_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../cart/presentation/cart_screen.dart';
import '../../home/presentation/home_screen.dart';
import '../../search/presentation/search_screen.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color maroonColor = Color(0xFF5D1A1A);
    const Color bgColor = Color(0xFFEFEFEF); 

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          title: Text(
            'Notifikasi',
            style: GoogleFonts.outfit(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen())),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 15),
                    child: Icon(Icons.shopping_cart_outlined, color: maroonColor, size: 28),
                  ),
                  Positioned(
                    right: 8,
                    top: 10,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(color: maroonColor, shape: BoxShape.circle),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text('3', style: GoogleFonts.outfit(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatListScreen())),
                child: Image.asset(
                  'assets/images/icons msg.png',
                  width: 28,
                  height: 28,
                  color: maroonColor,
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: Colors.white,
                child: Column(
                  children: [
                    _buildCategoryTile(
                      icon: Icons.confirmation_number_outlined,
                      title: 'Promo Ootday',
                      subtitle: 'Status Pesanan',
                      badgeCount: 10,
                    ),
                    const Divider(height: 1, indent: 70),
                    _buildCategoryTile(
                      icon: Icons.shopping_bag_outlined,
                      title: 'Info Ootday',
                      subtitle: 'Status Pesanan',
                      badgeCount: 5,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 20, 15, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Status Pesanan', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54)),
                    Text('Semua Notifikasi', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: maroonColor.withOpacity(0.8))),
                  ],
                ),
              ),
              
              // Perbaikan audit: sebelumnya notifikasi dimuat lewat stream
              // Firebase Firestore. Belum ada endpoint notifikasi di
              // backend Laravel (lihat API_CONTRACT.md), jadi untuk saat ini
              // ditampilkan konten default statis -- tidak ada lagi
              // ketergantungan ke Firebase yang sudah dihapus dari aplikasi.
              _buildNotificationCard(title: 'Selamat Datang!', desc: 'Terima kasih telah bergabung dengan Ootday. Cek promo menarik hari ini!'),
              _buildNotificationCard(title: 'Info Pesanan', desc: 'Pantau status pesanan Anda lewat menu "Pesanan Saya" di halaman Profil.'),
              const SizedBox(height: 20),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          height: 70,
          decoration: const BoxDecoration(color: maroonColor),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen())),
                child: Icon(Icons.home, color: Colors.white.withOpacity(0.5), size: 28),
              ),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchScreen())),
                child: Icon(Icons.search, color: Colors.white.withOpacity(0.5), size: 28),
              ),
              const Icon(Icons.notifications, color: Colors.white, size: 28),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
                child: Icon(Icons.person_outline, color: Colors.white.withOpacity(0.5), size: 28),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTile({required IconData icon, required String title, required String subtitle, required int badgeCount}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Icon(icon, color: const Color(0xFF5D1A1A), size: 24),
      ),
      title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
      subtitle: Text(subtitle, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(color: Color(0xFF5D1A1A), shape: BoxShape.circle),
            child: Text(
              '$badgeCount',
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 5),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildNotificationCard({required String title, required String desc}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF9F9), 
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: const Color(0xFF5D1A1A),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            desc,
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
