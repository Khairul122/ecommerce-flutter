import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'order_status_detail_page.dart';
import 'providers/order_provider.dart';

/// Ringkasan semua status pemesanan (dari "Riwayat >").
/// Perbaikan audit: sebelumnya jumlah tiap status di-hardcode di kode
/// (mis. 'Penilaian': 2). Sekarang jumlahnya diambil dari GET /owner/stats.
class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  static const Color _redMain = Color(0xFFB40001);
  static const Color _darkRed = Color(0xFF7A0000);
  static const Color _greyBg = Color(0xFFF2F2F2);

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadStats());
  }

  Future<void> _loadStats() => context.read<OrderProvider>().fetchStats();

  int _countFor(Map<String, dynamic>? stats, String key) {
    final value = stats?[key];
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final isLoading = orderProvider.isLoadingStats && orderProvider.stats == null;
    final stats = orderProvider.stats;
    final items = [
      (
        _countFor(stats, 'pesanan_menunggu_konfirmasi'),
        OrderStatusDetailData.menungguPembayaran,
      ),
      (_countFor(stats, 'pesanan_diproses'), OrderStatusDetailData.diproses),
      (_countFor(stats, 'pesanan_dikirim'), OrderStatusDetailData.dikirim),
      (_countFor(stats, 'pesanan_selesai'), OrderStatusDetailData.selesai),
      (_countFor(stats, 'pesanan_dibatalkan'), OrderStatusDetailData.dibatalkan),
    ];

    return Scaffold(
      backgroundColor: OrderHistoryPage._greyBg,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 48, bottom: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [OrderHistoryPage._redMain, OrderHistoryPage._darkRed],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const Text(
                  'Riwayat Pemesanan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadStats,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final (count, bucket) = items[index];
                        final title = bucket.$2;
                        return Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      OrderStatusDetailPage.forBucket(bucket),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: OrderHistoryPage._redMain
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '$count',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: OrderHistoryPage._redMain,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Icon(Icons.chevron_right,
                                      color: Colors.grey[400]),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
