import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../chat/presentation/chat_list_screen.dart';
import '../../search/presentation/search_screen.dart';
import 'order_details_screen.dart';
import 'providers/order_provider.dart';
import '../domain/entities/order_entity.dart';
import '../../review/presentation/add_review_screen.dart';
import '../../../core/theme/app_spacing.dart';

/// Perbaikan audit: sebelumnya hanya tab "Diproses" yang memuat data asli
/// (lewat OrderData.getActiveOrders()), tab lain (Belum Bayar, Dikirim,
/// Selesai, Dibatalkan) menampilkan widget statis/kosong atau data contoh
/// yang ditulis langsung di kode. Sekarang setiap tab memuat statusnya
/// masing-masing lewat GET /orders?status=... (via OrderProvider).
class MyOrdersScreen extends StatefulWidget {
  final int initialTabIndex;
  const MyOrdersScreen({super.key, this.initialTabIndex = 0});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _statusPerTab = <int, String>{
    0: 'menunggu_pembayaran',
    1: 'diproses',
    2: 'dikirim',
    3: 'selesai',
    // index 4 "Pengembalian" belum didukung backend (belum ada status
    // pengembalian di API), jadi tetap tampilan statis kosong.
    5: 'dibatalkan',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this, initialIndex: widget.initialTabIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color maroonColor = Color(0xFF5D1A1A);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFEFEFEF),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: maroonColor),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Pesanan Saya',
            style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          actions: [
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchScreen())),
              child: const Icon(Icons.search, color: Colors.black, size: 24),
            ),
            const SizedBox(width: 15),
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatListScreen())),
              child: Image.asset('assets/images/icons msg.png', width: 24, height: 24, color: maroonColor),
            ),
            const SizedBox(width: 20),
          ],
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: maroonColor,
            labelColor: maroonColor,
            unselectedLabelColor: Colors.black54,
            labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
            unselectedLabelStyle: GoogleFonts.outfit(fontSize: 14),
            tabs: const [
              Tab(text: 'Belum Bayar'),
              Tab(text: 'Diproses'),
              Tab(text: 'Dikirim'),
              Tab(text: 'Selesai'),
              Tab(text: 'Pengembalian'),
              Tab(text: 'Dibatalkan'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _StatusOrdersTab(status: _statusPerTab[0]!, maroonColor: maroonColor),
            _StatusOrdersTab(status: _statusPerTab[1]!, maroonColor: maroonColor),
            _StatusOrdersTab(status: _statusPerTab[2]!, maroonColor: maroonColor),
            _StatusOrdersTab(status: _statusPerTab[3]!, maroonColor: maroonColor),
            _buildComingSoonView(maroonColor),
            _StatusOrdersTab(status: _statusPerTab[5]!, maroonColor: maroonColor),
          ],
        ),
      ),
    );
  }

  Widget _buildComingSoonView(Color maroonColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_return_outlined, size: 80, color: maroonColor.withOpacity(0.5)),
          const SizedBox(height: 15),
          Text('Fitur Pengembalian Segera Hadir', style: GoogleFonts.outfit(color: Colors.black38, fontSize: 14)),
        ],
      ),
    );
  }
}

class _StatusOrdersTab extends StatefulWidget {
  final String status;
  final Color maroonColor;
  const _StatusOrdersTab({required this.status, required this.maroonColor});

  @override
  State<_StatusOrdersTab> createState() => _StatusOrdersTabState();
}

class _StatusOrdersTabState extends State<_StatusOrdersTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadOrders());
  }

  Future<void> _loadOrders() {
    return context.read<OrderProvider>().fetchOrders(status: widget.status);
  }

  String _formatRp(num value) {
    return 'Rp ${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final maroonColor = widget.maroonColor;
    final provider = context.watch<OrderProvider>();
    final isLoading = provider.isLoading(widget.status);
    final error = provider.errorFor(widget.status);
    final orders = provider.ordersFor(widget.status);

    if (isLoading && orders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null && orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text('Gagal memuat pesanan: $error', style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
            ),
            const SizedBox(height: 10),
            TextButton(onPressed: _loadOrders, child: const Text('Coba Lagi')),
          ],
        ),
      );
    }
    if (orders.isEmpty) {
      return _buildEmptyOrdersView(maroonColor);
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 15),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return _buildOrderCard(context, maroonColor, order);
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Color maroonColor, OrderEntity order) {
    final items = order.items;
    final firstItem = items.isNotEmpty ? items[0] : null;
    final storeName = order.storeName ?? 'Ootday Fashion Store';
    final image = firstItem?.imageUrl ?? 'assets/images/Produk_1.png';

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OrderDetailsScreen(orderId: order.id.toString())),
        );
        if (mounted) _loadOrders();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.storefront_outlined, size: 20, color: Colors.black),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          storeName,
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  order.orderCode,
                  style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            const Divider(height: 25),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: image.startsWith('assets/')
                      ? Image.asset(image, width: 70, height: 70, fit: BoxFit.cover)
                      : Image.network(image, width: 70, height: 70, fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(width: 70, height: 70, color: Colors.grey[200])),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        firstItem?.productName ?? 'Produk',
                        style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              firstItem?.variantLabel ?? '',
                              style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('${items.length} produk', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Align(
              alignment: Alignment.centerRight,
              child: Text('Total: ${_formatRp(order.totalPrice)}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
            if (order.status == 'completed' && firstItem != null) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: maroonColor,
                    side: BorderSide(color: maroonColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.star_outline, size: 16),
                  label: Text('Beri Ulasan', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddReviewScreen(
                          orderId: order.id,
                          productId: firstItem.productId,
                          productName: firstItem.productName,
                          productImage: firstItem.imageUrl ?? '',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyOrdersView(Color maroonColor) {
    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 60),
            Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 100, color: maroonColor.withOpacity(0.8)),
                    Positioned(bottom: 0, right: 0, child: Icon(Icons.help_outline, size: 30, color: maroonColor.withOpacity(0.5))),
                  ],
                ),
                const SizedBox(height: 15),
                Text('Belum Ada Pesanan', style: GoogleFonts.outfit(color: Colors.black38, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
