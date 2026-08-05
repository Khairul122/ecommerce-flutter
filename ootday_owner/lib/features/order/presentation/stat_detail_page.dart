import 'package:flutter/material.dart';

class StatDetailPage extends StatelessWidget {
  const StatDetailPage({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.showGraph = false,
    required this.summaryLines,
    required this.activities,
  });

  final String title;
  final String value;
  final IconData icon;
  final bool showGraph;
  final List<String> summaryLines;
  final List<StatActivityItem> activities;

  static const Color _redMain = Color(0xFFB40001);
  static const Color _darkRed = Color(0xFF7A0000);
  static const Color _greyBg = Color(0xFFF2F2F2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _greyBg,
      body: Column(
        children: [
          _header(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _summaryCard(),
                  const SizedBox(height: 20),
                  const Text(
                    'Ringkasan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _infoCard(
                    child: Column(
                      children: summaryLines
                          .map(
                            (line) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 8,
                                    color: _redMain.withValues(alpha: 0.6),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      line,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Aktivitas Terbaru',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (activities.isEmpty)
                    _infoCard(
                      child: Row(
                        children: [
                          Icon(Icons.inbox_outlined, color: Colors.grey[500]),
                          const SizedBox(width: 12),
                          Text(
                            'Belum ada aktivitas.',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  else
                    ...activities.map(_activityTile),
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
      padding: const EdgeInsets.only(top: 48, bottom: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_redMain, _darkRed],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _darkRed,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: _darkRed, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          if (showGraph)
            Icon(
              Icons.show_chart,
              color: Colors.white.withValues(alpha: 0.7),
              size: 28,
            ),
        ],
      ),
    );
  }

  Widget _infoCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _activityTile(StatActivityItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _infoCard(
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _redMain.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, color: _redMain, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Text(
              item.time,
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}

class StatActivityItem {
  const StatActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
}

/// Data demo per jenis statistik.
class StatDetailData {
  StatDetailData._();

  static StatDetailPage visitors() => StatDetailPage(
        title: 'Total Visitors',
        value: '857',
        icon: Icons.people,
        showGraph: true,
        summaryLines: const [
          'Pengunjung unik hari ini: 124',
          'Pengunjung minggu ini: 512',
          'Rata-rata durasi kunjungan: 2 menit 18 detik',
        ],
        activities: const [
          StatActivityItem(
            icon: Icons.person_add_alt_1,
            title: 'Pengunjung baru',
            subtitle: 'Dari pencarian "kaos oversized"',
            time: '10:24',
          ),
          StatActivityItem(
            icon: Icons.trending_up,
            title: 'Lonjakan kunjungan',
            subtitle: '+18% dibanding kemarin',
            time: '09:15',
          ),
          StatActivityItem(
            icon: Icons.storefront,
            title: 'Kunjungan profil toko',
            subtitle: '42 kali dilihat hari ini',
            time: '08:02',
          ),
        ],
      );

  static StatDetailPage orders() => StatDetailPage(
        title: 'Total Orders',
        value: '690',
        icon: Icons.shopping_bag,
        summaryLines: const [
          'Pesanan hari ini: 12',
          'Pesanan minggu ini: 89',
          'Nilai transaksi bulan ini: Rp 24.500.000',
        ],
        activities: const [
          StatActivityItem(
            icon: Icons.receipt_long,
            title: 'Pesanan #A7273G6453',
            subtitle: 'Kaos oversized polos coklat',
            time: '11:40',
          ),
          StatActivityItem(
            icon: Icons.receipt_long,
            title: 'Pesanan #B8392H7120',
            subtitle: 'Dress rajut tali bahu',
            time: '10:55',
          ),
          StatActivityItem(
            icon: Icons.check_circle_outline,
            title: 'Pesanan selesai',
            subtitle: 'Celana jeans biru cutbray',
            time: '09:30',
          ),
        ],
      );

  static StatDetailPage views() => StatDetailPage(
        title: 'Total Views',
        value: '1213',
        icon: Icons.visibility,
        showGraph: true,
        summaryLines: const [
          'Tayangan produk hari ini: 286',
          'Produk paling dilihat: Kaos oversized coklat',
          'CTR ke keranjang: 4,2%',
        ],
        activities: const [
          StatActivityItem(
            icon: Icons.remove_red_eye,
            title: 'Produk dilihat 48×',
            subtitle: 'Kaos oversized polos coklat',
            time: '12:01',
          ),
          StatActivityItem(
            icon: Icons.remove_red_eye,
            title: 'Produk dilihat 31×',
            subtitle: 'Dress rajut + blouse putih',
            time: '11:22',
          ),
          StatActivityItem(
            icon: Icons.remove_red_eye,
            title: 'Produk dilihat 27×',
            subtitle: 'Celana jeans biru cutbray',
            time: '10:48',
          ),
        ],
      );

  static StatDetailPage conversation() => StatDetailPage(
        title: 'Conversation',
        value: '83%',
        icon: Icons.chat_bubble,
        summaryLines: const [
          'Chat aktif: 14 percakapan',
          'Rata-rata balasan: 8 menit',
          'Tingkat konversi chat ke order: 23%',
        ],
        activities: const [
          StatActivityItem(
            icon: Icons.chat,
            title: 'Chat dengan Vanya',
            subtitle: 'Pertanyaan stok ukuran L',
            time: '12:30',
          ),
          StatActivityItem(
            icon: Icons.chat,
            title: 'Chat dengan Amelia',
            subtitle: 'Konfirmasi warna biru',
            time: '10:00',
          ),
          StatActivityItem(
            icon: Icons.mark_chat_read,
            title: 'Percakapan ditutup',
            subtitle: 'Pembeli Citra — stok habis',
            time: 'Kemarin',
          ),
        ],
      );
}
