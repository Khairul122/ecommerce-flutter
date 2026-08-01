import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../cart/presentation/cart_screen.dart';
import '../../chat/presentation/chat_list_screen.dart';
import '../../chat/presentation/chat_detail_screen.dart';
import '../../../core/services/api_service.dart';
import '../domain/entities/order_entity.dart';
import '../domain/entities/order_item_entity.dart';
import 'providers/order_provider.dart';

/// Perbaikan audit: layar ini sebelumnya adalah StatelessWidget TANPA
/// parameter apa pun, jadi setiap pesanan (apapun statusnya) menampilkan
/// data identik yang ditulis langsung di kode. Sekarang menerima [orderId]
/// dan memuat data pesanan sungguhan lewat GET /orders/{id} (via
/// OrderProvider). Tombol "Batalkan Pesanan" yang sebelumnya
/// `onPressed: () {}` (tidak berbuat apa-apa) sekarang benar-benar
/// memanggil POST /orders/{id}/cancel.
class OrderDetailsScreen extends StatefulWidget {
  final String orderId;
  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() {
    return context.read<OrderProvider>().fetchOrderDetail(widget.orderId);
  }

  Future<void> _cancelOrder() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Batalkan Pesanan', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text('Apakah Anda yakin ingin membatalkan pesanan ini?', style: GoogleFonts.outfit()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Tidak')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Batalkan', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await context.read<OrderProvider>().cancelOrder(widget.orderId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pesanan berhasil dibatalkan')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membatalkan pesanan: $e')),
        );
      }
    }
  }

  Future<void> _contactSeller(BuildContext context, OrderEntity? order) async {
    final storeId = order?.storeId;
    final storeName = order?.storeName ?? 'Toko';
    if (storeId == null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatListScreen()));
      return;
    }
    try {
      final result = await ApiService().post('/conversations', {'store_id': storeId});
      final conversation = Map<String, dynamic>.from(result['data'] ?? {});
      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatDetailScreen(
            conversationId: conversation['id'].toString(),
            storeName: storeName,
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuka percakapan: $e')),
        );
      }
    }
  }

  String _formatRp(num value) {
    return 'Rp ${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    const Color maroonColor = Color(0xFF5D1A1A);
    const Color lightPinkBg = Color(0xFFF8F3F3);

    final provider = context.watch<OrderProvider>();
    final order = provider.selectedOrder;
    final isLoading = provider.detailLoading;
    final error = provider.detailError;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: maroonColor),
            onPressed: () => Navigator.pop(context, order),
          ),
          title: Text(
            'Rincian Pesanan',
            style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          actions: [
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen())),
              child: const Padding(
                padding: EdgeInsets.only(right: 20, top: 10),
                child: Icon(Icons.shopping_cart_outlined, color: maroonColor, size: 28),
              ),
            ),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : (error != null && order == null)
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Text('Gagal memuat detail pesanan: $error', style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                        ),
                        const SizedBox(height: 10),
                        TextButton(onPressed: _loadOrder, child: const Text('Coba Lagi')),
                      ],
                    ),
                  )
                : order == null
                    ? const Center(child: Text('Pesanan tidak ditemukan'))
                    : _buildOrderBody(order, maroonColor, lightPinkBg),
        bottomSheet: (isLoading || order == null)
            ? null
            : _buildBottomButtons(context, order, maroonColor, provider.isMutating),
      ),
    );
  }

  Widget _buildOrderBody(OrderEntity order, Color maroonColor, Color lightPinkBg) {
    final items = order.items;
    final status = order.status;
    final paymentStatus = order.paymentStatus;
    final totalPrice = order.totalPrice;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: lightPinkBg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _statusLabel(status, paymentStatus),
                  style: GoogleFonts.outfit(color: maroonColor, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 5),
                Text(
                  order.cancelReason ?? _statusDescription(status, paymentStatus),
                  style: GoogleFonts.outfit(color: Colors.black87, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Info Pengiriman', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Icon(Icons.inventory_2, color: maroonColor, size: 30),
                    const SizedBox(width: 15),
                    Text(order.shippingMethodName ?? '-', style: GoogleFonts.outfit(fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Alamat Pengiriman', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: lightPinkBg,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on, color: maroonColor, size: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${order.receiverName ?? '-'} (${order.receiverPhone ?? '-'})',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              order.shippingAddress ?? '-',
                              style: GoogleFonts.outfit(fontSize: 12, color: Colors.black54, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.storefront_outlined, size: 20, color: Colors.black),
                    const SizedBox(width: 10),
                    Text(order.storeName ?? 'Toko', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 15),
                ...items.map(_buildOrderItemRow),
                const SizedBox(height: 15),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('Total Pembayaran: ${_formatRp(totalPrice)}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ],
            ),
          ),
          const Divider(height: 40),
          _buildInfoSection(order),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildOrderItemRow(OrderItemEntity item) {
    final String image = item.imageUrl;
    final num price = item.price;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: image.startsWith('assets/')
                ? Image.asset(image, width: 60, height: 60, fit: BoxFit.cover)
                : Image.network(image, width: 60, height: 60, fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(width: 60, height: 60, color: Colors.grey[200])),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500), maxLines: 2),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.variantLabel ?? '', style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey)),
                    Text('x${item.quantity}', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                Text(_formatRp(price), style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(OrderEntity order) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildTextRowWithCopy('No. Pesanan', order.orderCode.isNotEmpty ? order.orderCode : '-'),
          const Divider(height: 30),
          _buildTextRow('Metode Pembayaran', order.paymentMethodName ?? '-', icon: Icons.account_balance_wallet, iconColor: Colors.blue),
          const Divider(height: 30),
          _buildTextRow('Waktu Pemesanan', order.orderedAt ?? '-'),
        ],
      ),
    );
  }

  String _statusLabel(String status, String paymentStatus) {
    if (status == 'dibatalkan') return 'Pesanan Dibatalkan';
    if (status == 'selesai') return 'Pesanan Selesai';
    if (status == 'dikirim') return 'Pesanan Sedang Dikirim';
    if (status == 'diproses') return 'Pesanan Sedang Disiapkan';
    if (paymentStatus == 'menunggu_konfirmasi') return 'Menunggu Verifikasi Pembayaran';
    return 'Menunggu Pembayaran';
  }

  String _statusDescription(String status, String paymentStatus) {
    if (status == 'dibatalkan') return 'Pesanan ini telah dibatalkan.';
    if (status == 'selesai') return 'Pesanan telah sampai ke tujuan.';
    if (status == 'dikirim') return 'Pesanan Anda sedang dalam perjalanan.';
    if (status == 'diproses') return 'Pesanan Anda sedang disiapkan oleh toko.';
    if (paymentStatus == 'menunggu_konfirmasi') return 'Pesanan akan diproses setelah toko memverifikasi pembayaran Anda.';
    return 'Segera selesaikan pembayaran untuk pesanan ini.';
  }

  Widget _buildTextRow(String label, String value, {IconData? icon, Color? iconColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.outfit(color: Colors.black87, fontSize: 13)),
        const SizedBox(width: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 5),
            ],
            Text(value, style: GoogleFonts.outfit(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }

  Widget _buildTextRowWithCopy(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.outfit(color: Colors.black87, fontSize: 13)),
        Row(
          children: [
            Text(value, style: GoogleFonts.outfit(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label disalin!')));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(border: Border.all(color: Colors.black26), borderRadius: BorderRadius.circular(20)),
                child: Text('Salin', style: GoogleFonts.outfit(fontSize: 10)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomButtons(BuildContext context, OrderEntity order, Color maroonColor, bool isMutating) {
    final status = order.status;
    final bool canCancel = status == 'menunggu_pembayaran' || status == 'diproses';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.black12))),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: (canCancel && !isMutating) ? _cancelOrder : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canCancel ? maroonColor : Colors.grey,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: isMutating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text('Batalkan Pesanan', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _contactSeller(context, order),
              style: ElevatedButton.styleFrom(
                backgroundColor: maroonColor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Hubungi Penjual', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
