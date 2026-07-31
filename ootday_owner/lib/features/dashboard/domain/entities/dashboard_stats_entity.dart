/// Statistik dashboard owner dari GET /owner/stats, dipakai di
/// `home_page.dart` (kartu statistik + status pemesanan).
class DashboardStatsEntity {
  final int totalPesanan;
  final int totalProduk;
  final int pesananDikirim;
  final num totalPendapatan;
  final int pesananMenungguKonfirmasi;
  final int pesananDiproses;
  final int pesananDibatalkan;

  const DashboardStatsEntity({
    required this.totalPesanan,
    required this.totalProduk,
    required this.pesananDikirim,
    required this.totalPendapatan,
    required this.pesananMenungguKonfirmasi,
    required this.pesananDiproses,
    required this.pesananDibatalkan,
  });
}
