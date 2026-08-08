import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../domain/entities/order_entity.dart';

class TrackingScreen extends StatelessWidget {
  final OrderEntity order;
  const TrackingScreen({super.key, required this.order});

  static const Color maroonColor = Color(0xFF5D1A1A);
  static const Color darkRed = Color(0xFF7A0000);

  @override
  Widget build(BuildContext context) {
    final resi = order.trackingNumber ?? '-';
    final courierName = order.courierDisplay;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: maroonColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Lacak Pengiriman (Simulasi)',
          style: GoogleFonts.outfit(color: maroonColor, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade300),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER INFO CARD
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(order.orderCode, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: maroonColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            order.status.toUpperCase(),
                            style: GoogleFonts.outfit(color: maroonColor, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    _buildRowInfo('Kurir & Layanan', courierName),
                    const SizedBox(height: 8),
                    _buildRowInfo('Nomor Resi', resi, isCopyable: true),
                    const SizedBox(height: 8),
                    _buildRowInfo('Estimasi Tiba', order.shippingEtd ?? '2-3 hari'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Status Perjalanan (Simulasi Status Real-time)',
              style: GoogleFonts.outfit(color: maroonColor, fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // TRACKING TIMELINE
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: _buildTimelineSteps(context),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.amber),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Nomor resi & tracking status di atas dihasilkan via sistem simulasi ekspedisi RajaOngkir Ootday.',
                      style: GoogleFonts.outfit(fontSize: 12, color: Colors.brown.shade800),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRowInfo(String label, String value, {bool isCopyable = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.outfit(color: Colors.grey.shade600, fontSize: 13)),
        Text(value, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: isCopyable ? darkRed : Colors.black87)),
      ],
    );
  }

  List<Widget> _buildTimelineSteps(BuildContext context) {
    final status = order.status;
    final resi = order.trackingNumber ?? 'JNE' + order.id.toString().padLeft(8, '0');

    final steps = [
      _TimelineItem(
        title: 'Pesanan Dibuat',
        subtitle: 'Pelanggan telah membuat pesanan',
        time: order.orderedAt ?? 'Hari ini',
        isDone: true,
        isCurrent: status == 'menunggu_pembayaran',
      ),
      _TimelineItem(
        title: 'Pembayaran Dikonfirmasi',
        subtitle: 'Pembayaran berhasil diverifikasi',
        time: order.orderedAt ?? 'Hari ini',
        isDone: status != 'menunggu_pembayaran',
        isCurrent: status == 'diproses',
      ),
      _TimelineItem(
        title: 'Diserahkan ke Kurir Ekspedisi',
        subtitle: 'Resi Pengiriman: $resi',
        time: status == 'dikirim' || status == 'selesai' ? 'Hari ini' : '-',
        isDone: status == 'dikirim' || status == 'selesai',
        isCurrent: status == 'dikirim',
      ),
      _TimelineItem(
        title: 'Dalam Perjalanan Ke Alamat Tujuan',
        subtitle: 'Kurir membawa paket menuju kota tujuan',
        time: status == 'dikirim' || status == 'selesai' ? 'Sedang Diproses' : '-',
        isDone: status == 'dikirim' || status == 'selesai',
        isCurrent: false,
      ),
      _TimelineItem(
        title: 'Pesanan Tiba & Selesai',
        subtitle: 'Paket telah diterima oleh penerima',
        time: status == 'selesai' ? 'Selesai' : '-',
        isDone: status == 'selesai',
        isCurrent: status == 'selesai',
      ),
    ];

    return List.generate(steps.length, (index) {
      final step = steps[index];
      final isLast = index == steps.length - 1;

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: step.isDone ? maroonColor : Colors.grey.shade300,
                ),
                child: Icon(
                  step.isDone ? Icons.check : Icons.circle,
                  size: 14,
                  color: Colors.white,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 45,
                  color: step.isDone ? maroonColor : Colors.grey.shade300,
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: GoogleFonts.outfit(
                    fontWeight: step.isCurrent ? FontWeight.bold : FontWeight.w600,
                    fontSize: 14,
                    color: step.isDone ? Colors.black87 : Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  step.subtitle,
                  style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _TimelineItem {
  final String title;
  final String subtitle;
  final String time;
  final bool isDone;
  final bool isCurrent;

  _TimelineItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.isDone,
    required this.isCurrent,
  });
}
