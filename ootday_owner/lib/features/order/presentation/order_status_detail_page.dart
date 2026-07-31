import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/entities/order_entity.dart';
import '../domain/usecases/order_usecases.dart';
import 'providers/order_provider.dart';

/// Bucket status pesanan yang benar-benar ada di backend (kolom `status`
/// pada tabel orders): menunggu_pembayaran|diproses|dikirim|selesai|dibatalkan.
/// Perbaikan audit: sebelumnya halaman ini menampilkan angka & daftar pesanan
/// yang di-hardcode ('Perlu Dikirim', 'Pembatalan', 'Pengembalian', 'Penilaian'
/// dengan data statis), sekarang mengambil data sungguhan dari
/// GET /owner/orders?status=... dan menyediakan aksi terima/tolak/update
/// status yang benar-benar memanggil API.
class OrderStatusDetailData {
  OrderStatusDetailData._();

  static const menungguPembayaran = (
    'menunggu_pembayaran',
    'Menunggu Konfirmasi',
    'Pesanan yang sudah dibuat pembeli dan menunggu konfirmasi pembayaran.',
  );
  static const diproses = (
    'diproses',
    'Diproses',
    'Pesanan yang sudah dibayar dan sedang disiapkan toko.',
  );
  static const dikirim = (
    'dikirim',
    'Dikirim',
    'Pesanan yang sedang dalam pengiriman ke pembeli.',
  );
  static const selesai = (
    'selesai',
    'Selesai',
    'Pesanan yang sudah diterima pembeli.',
  );
  static const dibatalkan = (
    'dibatalkan',
    'Pembatalan',
    'Pesanan yang dibatalkan oleh pembeli atau toko.',
  );
}

class OrderStatusDetailPage extends StatefulWidget {
  const OrderStatusDetailPage({
    super.key,
    required this.status,
    required this.title,
    required this.description,
  });

  /// Salah satu dari OrderStatusDetailData (status, title, description).
  factory OrderStatusDetailPage.forBucket(
    (String, String, String) bucket,
  ) {
    return OrderStatusDetailPage(
      status: bucket.$1,
      title: bucket.$2,
      description: bucket.$3,
    );
  }

  final String status;
  final String title;
  final String description;

  static const Color _redMain = Color(0xFFB40001);
  static const Color _darkRed = Color(0xFF7A0000);
  static const Color _greyBg = Color(0xFFF2F2F2);

  @override
  State<OrderStatusDetailPage> createState() => _OrderStatusDetailPageState();
}

class _OrderStatusDetailPageState extends State<OrderStatusDetailPage> {
  List<OrderEntity> _orders = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadOrders());
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final orders =
          await context.read<OrderProvider>().getOrdersUseCase(
                GetOrdersParams(status: widget.status),
              );
      if (!mounted) return;
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatus(int orderId, String newStatus) async {
    try {
      await context.read<OrderProvider>().updateStatus(
            orderId,
            status: newStatus,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Status pesanan diperbarui'),
          backgroundColor: Colors.green,
        ),
      );
      _loadOrders();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui status: $e')),
      );
    }
  }

  Future<void> _confirmPayment(int orderId) async {
    try {
      await context.read<OrderProvider>().confirmPayment(orderId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pembayaran dikonfirmasi'),
          backgroundColor: Colors.green,
        ),
      );
      _loadOrders();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal konfirmasi pembayaran: $e')),
      );
    }
  }

  Future<void> _confirmCancel(int orderId) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Batalkan Pesanan'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(hintText: 'Alasan pembatalan'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Ya, Batalkan', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    reasonController.dispose();
    if (confirmed != true) return;
    await _updateStatus(orderId, 'dibatalkan');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OrderStatusDetailPage._greyBg,
      body: Column(
        children: [
          _header(context),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadOrders,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _summaryCard(),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Daftar Pesanan',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${_orders.length} item',
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (_error != null)
                            _errorState()
                          else if (_orders.isEmpty)
                            _emptyState()
                          else
                            ..._orders.map(_orderCard),
                        ],
                      ),
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
          colors: [OrderStatusDetailPage._redMain, OrderStatusDetailPage._darkRed],
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
          Expanded(
            child: Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
        color: OrderStatusDetailPage._redMain,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            '${_orders.length}',
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.9)),
          ),
        ],
      ),
    );
  }

  Widget _errorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
          const SizedBox(height: 12),
          Text('Gagal memuat pesanan: $_error', textAlign: TextAlign.center),
          const SizedBox(height: 12),
          TextButton(onPressed: _loadOrders, child: const Text('Coba lagi')),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'Belum ada pesanan',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Pesanan dengan status ini akan muncul di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _orderCard(OrderEntity order) {
    final id = order.id;
    final code = order.orderCode;
    final items = order.items;
    final firstItem = items.isNotEmpty ? items.first : null;
    final productName = firstItem?.productName ?? 'Produk';
    final extraCount = items.length > 1 ? items.length - 1 : 0;
    final totalPrice = order.totalPrice;
    final priceStr = _formatPrice(totalPrice);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 56,
                  height: 56,
                  color: Colors.grey[200],
                  child: const Icon(Icons.shopping_bag_outlined, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      extraCount > 0 ? '$productName +$extraCount lainnya' : productName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      code,
                      style: const TextStyle(
                        fontSize: 12,
                        color: OrderStatusDetailPage._redMain,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Rp $priceStr',
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
          ..._actionsFor(order, id),
        ],
      ),
    );
  }

  List<Widget> _actionsFor(OrderEntity order, int id) {
    final status = order.status;
    final paymentStatus = order.paymentStatus;
    final actions = <Widget>[];

    if (status == 'menunggu_pembayaran' && paymentStatus == 'menunggu_konfirmasi') {
      actions.add(_actionButton(
        label: 'Konfirmasi Pembayaran',
        color: Colors.green,
        onTap: () => _confirmPayment(id),
      ));
    } else if (status == 'diproses') {
      actions.add(_actionButton(
        label: 'Tandai Dikirim',
        color: Colors.blue,
        onTap: () => _updateStatus(id, 'dikirim'),
      ));
    } else if (status == 'dikirim') {
      actions.add(_actionButton(
        label: 'Tandai Selesai',
        color: Colors.green,
        onTap: () => _updateStatus(id, 'selesai'),
      ));
    }

    if (status == 'menunggu_pembayaran' || status == 'diproses') {
      actions.add(_actionButton(
        label: 'Batalkan',
        color: Colors.red,
        onTap: () => _confirmCancel(id),
      ));
    }

    if (actions.isEmpty) return [];

    return [
      const SizedBox(height: 10),
      Row(children: actions.map((a) => Expanded(child: a)).toList()),
    ];
  }

  Widget _actionButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SizedBox(
        height: 36,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            foregroundColor: color,
            side: BorderSide(color: color),
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: Text(label, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }

  String _formatPrice(dynamic price) {
    final value = price is num ? price.toInt() : (num.tryParse('$price')?.toInt() ?? 0);
    return value.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
