import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../product/presentation/detail_produk.dart';
import '../../product/presentation/providers/product_provider.dart';
import '../../product/domain/entities/product_entity.dart';
import '../../order/presentation/providers/order_provider.dart';
import '../../order/domain/entities/order_entity.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final Color redMain = const Color(0xFFB40001);
  final Color greyBG = const Color(0xFFF2F2F2);

  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final productProvider = context.read<ProductProvider>();
    final orderProvider = context.read<OrderProvider>();
    try {
      await Future.wait([
        productProvider.loadProducts(),
        if (productProvider.categories.isEmpty) productProvider.loadCategories(),
        orderProvider.fetchOrders(),
      ]);
    } catch (_) {
      // Provider sudah menyimpan pesan error masing-masing; halaman ini
      // hanya menampilkan state kosong/hasil pencarian kosong.
    }
    if (mounted) {
      _onSearchChanged();
    }
  }

  String _categoryNameFor(ProductEntity product, ProductProvider provider) {
    if (product.categoryId == null) return '';
    for (final category in provider.categories) {
      if (category.id == product.categoryId) return category.name;
    }
    return '';
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    final productProvider = context.read<ProductProvider>();
    final orderProvider = context.read<OrderProvider>();

    setState(() {
      _isSearching = true;
      _searchResults = [];

      // Search in products
      for (final product in productProvider.products) {
        final name = product.name.toLowerCase();
        final category = _categoryNameFor(product, productProvider).toLowerCase();
        if (name.contains(query) || category.contains(query)) {
          _searchResults.add({
            'type': 'product',
            'data': {
              'name': product.name,
              'price': product.price.toInt(),
              'image': product.primaryImageUrl,
              'category': _categoryNameFor(product, productProvider),
              'description': product.description,
              'variants': product.variants,
            },
          });
        }
      }

      // Search in orders
      for (final order in orderProvider.orders) {
        final title = _orderTitle(order).toLowerCase();
        final code = order.orderCode.toLowerCase();
        if (title.contains(query) || code.contains(query)) {
          _searchResults.add({
            'type': 'order',
            'data': {
              'title': _orderTitle(order),
              'code': '#${order.orderCode}',
              'image': _orderImage(order),
              'quantity': '(${_orderQuantity(order)})',
            },
          });
        }
      }
    });
  }

  String _orderTitle(OrderEntity order) {
    if (order.items.isEmpty) return order.orderCode;
    return order.items.map((item) => item.productName).join(', ');
  }

  int _orderQuantity(OrderEntity order) {
    if (order.items.isEmpty) return 0;
    return order.items.fold<int>(0, (sum, item) => sum + item.quantity);
  }

  String _orderImage(OrderEntity order) {
    if (order.items.isEmpty) return '';
    final raw = order.items.first.raw;
    final image = raw['image'] ?? raw['image_url'] ?? raw['product_image'];
    return image is String ? image : '';
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ProductProvider>().isLoadingProducts ||
        context.watch<OrderProvider>().isLoadingOrders;
    return Scaffold(
      backgroundColor: greyBG,
      body: Column(
        children: [
          _header(),
          _searchBar(),
          Expanded(
            child: isLoading && _searchResults.isEmpty && _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _buildResults(),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: redMain,
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: Center(
                child: Image.asset(
                  'assets/logo.png',
                  height: 32,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Text(
                    'ootday',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 48), // Balance for back button
          ],
        ),
      ),
    );
  }

  Widget _searchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: greyBG,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.black87),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Cari produk atau pesanan...",
                  hintStyle: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                onSubmitted: (_) {
                  // Search is handled by listener
                },
              ),
            ),
            if (_searchController.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                },
                child: const Icon(Icons.clear, color: Colors.black54, size: 20),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (!_isSearching && _searchController.text.isEmpty) {
      return _buildEmptyState('Mulai ketik untuk mencari produk atau pesanan');
    }

    if (_searchResults.isEmpty && _isSearching) {
      return _buildEmptyState('Tidak ada hasil ditemukan');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        if (result['type'] == 'product') {
          return _buildProductCard(result['data']);
        } else {
          return _buildOrderCard(result['data']);
        }
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailProduk(
              name: product['name'] as String,
              price: product['price'] as int,
              image: product['image'] as String,
              description: product['description'] as String?,
              variants: (product['variants'] as List<ProductVariantEntity>?) ?? const [],
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildImage(product['image'] as String),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product['category'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${_formatPrice(product['price'] as int)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: redMain,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildImage(order['image'] as String),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order['title'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      order['quantity'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        order['code'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: redMain,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: redMain.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Pesanan',
              style: TextStyle(
                fontSize: 10,
                color: redMain,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String image) {
    Widget fallback() => Container(
          width: 80,
          height: 80,
          color: Colors.grey[300],
          child: const Icon(Icons.image, size: 30),
        );

    final trimmed = image.trim();
    if (trimmed.isEmpty) return fallback();

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return Image.network(
        trimmed,
        width: 80,
        height: 80,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => fallback(),
      );
    }

    if (trimmed.startsWith('assets/images/')) {
      final fileName = trimmed.replaceFirst('assets/images/', '');
      final serverUrl = 'https://backend-ecommerce.synectra.xyz/storage/seed_images/$fileName';
      return Image.network(
        serverUrl,
        width: 80,
        height: 80,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) {
          return Image.asset(
            trimmed,
            width: 80,
            height: 80,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => fallback(),
          );
        },
      );
    }

    if (trimmed.startsWith('assets/')) {
      return Image.asset(
        trimmed,
        width: 80,
        height: 80,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => fallback(),
      );
    }

    final cleanPath = trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;
    final fullUrl = 'https://backend-ecommerce.synectra.xyz/$cleanPath';

    return Image.network(
      fullUrl,
      width: 80,
      height: 80,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => fallback(),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}

