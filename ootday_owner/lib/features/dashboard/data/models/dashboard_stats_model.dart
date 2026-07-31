import '../../domain/entities/dashboard_stats_entity.dart';

int _asInt(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? 0;
}

num _asNum(dynamic value) {
  if (value is num) return value;
  return num.tryParse('$value') ?? 0;
}

class DashboardStatsModel extends DashboardStatsEntity {
  const DashboardStatsModel({
    required super.totalPesanan,
    required super.totalProduk,
    required super.pesananDikirim,
    required super.totalPendapatan,
    required super.pesananMenungguKonfirmasi,
    required super.pesananDiproses,
    required super.pesananDibatalkan,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalPesanan: _asInt(json['total_pesanan']),
      totalProduk: _asInt(json['total_produk']),
      pesananDikirim: _asInt(json['pesanan_dikirim']),
      totalPendapatan: _asNum(json['total_pendapatan']),
      pesananMenungguKonfirmasi: _asInt(json['pesanan_menunggu_konfirmasi']),
      pesananDiproses: _asInt(json['pesanan_diproses']),
      pesananDibatalkan: _asInt(json['pesanan_dibatalkan']),
    );
  }
}
