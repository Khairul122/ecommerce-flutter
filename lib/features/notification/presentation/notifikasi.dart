import 'package:flutter/material.dart';
import 'package:ootday_owner/core/widgets/owner_bottom_nav.dart';
import '../../home/presentation/home_page.dart';

class NotifikasiPage extends StatelessWidget {
  const NotifikasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ===================== APPBAR MERAH GRADIENT =====================
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xffb30505), Color(0xffd92b2b)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, top: 15),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HomePage(),
                          ),
                        );
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
                    "Notifikasi",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // ===================== BODY =====================
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            children: const [
              NotifCard(
                title: "Pesanan tiba",
                desc:
                    "Pesanan 2498761khpsdm dengan no. resi BMLH12JK7 telah tiba di tujuan.",
              ),
              SizedBox(height: 15),

              NotifCard(
                title: "Pesanan segera tiba!",
                desc: "Pesanan sedang diantarkan menuju alamat anda.",
              ),
              SizedBox(height: 15),

              NotifCard(
                title: "Menunggu Pembayaran!",
                desc:
                    "Mohon lakukan pembayaran sebesar Rp89.000 sebelum 25-10-2025 24:00.",
              ),
              SizedBox(height: 15),

              NotifCard(
                title: "Pesanan dikirim!",
                desc:
                    "Pesanan 2498761khpsdm dengan no. resi BMLH12JK7 telah diserahkan ke jasa kirim. Periksa selengkapnya..",
              ),
              SizedBox(height: 15),

              NotifCard(
                title: "Pesanan dibuat!",
                desc:
                    "Pesanan 2498761khpsdm dengan no. resi BMLH12JK7 sedang di proses. Periksa selengkapnya..",
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),

      bottomNavigationBar: const OwnerBottomNav(currentIndex: 2),
    );
  }
}

// ====================== NOTIF CARD ======================
class NotifCard extends StatelessWidget {
  final String title;
  final String desc;

  const NotifCard({
    super.key,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xffe7e7e7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xffb30505),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
