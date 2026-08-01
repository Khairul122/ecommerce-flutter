import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../search/presentation/search_screen.dart';
import '../../chat/presentation/chat_list_screen.dart';
import '../../search/presentation/search_result_screen.dart';
import '../../cart/presentation/cart_screen.dart';
import '../../notification/presentation/notification_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../product/presentation/product_detail_screen.dart';
import 'package:provider/provider.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../product/presentation/providers/product_provider.dart';
import '../../product/domain/entities/product_entity.dart';
import '../../cart/presentation/providers/cart_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _bannerController = PageController();
  int _currentBanner = 0;
  Timer? _bannerTimer;

  final List<Map<String, dynamic>> _banners = [
    {
      'title': 'Dress in Style\n&\nSave More',
      'subtitle': 'Trendy fashion, best deals!',
      'color': const Color(0xFF5D1A1A),
      'image': 'assets/images/iklan.png',
    },
    {
      'title': 'Special Offer\nDiskon 50%',
      'subtitle': 'Koleksi Terbaru!',
      'color': const Color(0xFF7F0909),
      'image': 'assets/images/Iklan_2.png', 
    },
    {
      'title': 'New Arrival\nTrending Now',
      'subtitle': 'Cek koleksinya sekarang',
      'color': const Color(0xFF4A1414),
      'image': 'assets/images/iklan_3.png',
    },
    {
      'title': 'Voucher Belanja\nHingga 100rb',
      'subtitle': 'Klaim sekarang juga!',
      'color': const Color(0xFF3E0D0D),
      'image': 'assets/images/iklan_4.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startBannerTimer();
    _fetchData();
    _refreshUserSilently();
  }

  // Segarkan data user dari server (menggantikan sinkronisasi manual ke
  // Firestore/MySQL yang lama). Dibiarkan diam-diam gagal karena bukan
  // request kritikal untuk menampilkan beranda.
  Future<void> _refreshUserSilently() async {
    try {
      await context.read<AuthProvider>().refreshMe();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Gagal menyegarkan data user: $e');
    }
  }

  Future<void> _fetchData() async {
    final productProvider = context.read<ProductProvider>();
    try {
      await Future.wait([
        productProvider.fetchCategories(),
        productProvider.fetchProducts(perPage: 12),
      ]);
      try {
        await context.read<CartProvider>().loadCart();
      } catch (e) {
        debugPrint('Error fetching cart count: $e');
      }
    } catch (e) {
      debugPrint('Error fetching data via provider: $e');
    }
  }

  Future<void> _refreshCartCount() async {
    try {
      await context.read<CartProvider>().loadCart();
    } catch (e) {
      debugPrint('Error refreshing cart count: $e');
    }
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_bannerController.hasClients) {
        if (_currentBanner < _banners.length - 1) {
          _currentBanner++;
        } else {
          _currentBanner = 0;
        }
        _bannerController.animateToPage(
          _currentBanner,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final productProvider = context.watch<ProductProvider>();
    final cartCount = context.watch<CartProvider>().items.fold<int>(
          0,
          (sum, item) => sum + item.quantity,
        );
    const Color maroonColor = Color(0xFF5D1A1A);
    const Color bgColor = Color(0xFFEEE4E4);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Container(
                  padding: const EdgeInsets.all(20),
                  color: bgColor,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchScreen())).then((_) => _refreshCartCount()),
                              child: Container(
                                height: 45,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
                                child: Row(
                                  children: [
                                    Icon(Icons.search, color: maroonColor.withOpacity(0.5), size: 20),
                                    const SizedBox(width: 10),
                                    Expanded(child: Text('search', style: GoogleFonts.outfit(color: maroonColor.withOpacity(0.5)))),
                                    Icon(Icons.photo_camera_outlined, color: maroonColor.withOpacity(0.5), size: 20),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                           GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen())).then((_) => _refreshCartCount()),
                            child: Stack(
                              children: [
                                const Icon(Icons.shopping_cart_outlined, color: maroonColor, size: 28),
                                if (cartCount > 0)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(color: maroonColor, shape: BoxShape.circle),
                                      constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                                      child: Text(
                                        '$cartCount',
                                        style: GoogleFonts.outfit(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 15),
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatListScreen())),
                            child: Image.asset('assets/images/icons msg.png', width: 28, height: 28, color: maroonColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hi, ${user?.displayName ?? user?.email ?? 'vanya123@gmail.com'}', 
                                  style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: maroonColor),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                Text('Selamat datang di Ootday', style: GoogleFonts.outfit(fontSize: 14, color: maroonColor.withOpacity(0.7))),
                              ],
                            ),
                          ),
                          const CircleAvatar(radius: 35, backgroundColor: Colors.white, child: CircleAvatar(radius: 32, backgroundImage: AssetImage('assets/images/profile.png'))),
                        ],
                      ),
                    ],
                  ),
                ),

                // AUTO SCROLL BANNER SECTION
                SizedBox(
                  height: 200,
                  child: PageView.builder(
                    controller: _bannerController,
                    onPageChanged: (index) => setState(() => _currentBanner = index),
                    itemCount: _banners.length,
                    itemBuilder: (context, index) {
                      final banner = _banners[index];
                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: banner['color'],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      banner['title'],
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, height: 1.2),
                                    ),
                                    const SizedBox(height: 15),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(15)),
                                      child: Text(banner['subtitle'], style: GoogleFonts.outfit(color: banner['color'], fontSize: 12, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                right: 10, bottom: 0, top: 0,
                                child: Image.asset(banner['image'], fit: BoxFit.contain),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // BANNER INDICATOR
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _banners.asMap().entries.map((entry) {
                    return Container(
                      width: _currentBanner == entry.key ? 20 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: _currentBanner == entry.key ? maroonColor : Colors.grey[300],
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 15),
                // Categories Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Kategori', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: maroonColor)),
                      const SizedBox(height: 15),
                      productProvider.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : (productProvider.error != null && productProvider.error!.isNotEmpty)
                              ? Center(
                                  child: Column(
                                    children: [
                                      Text(productProvider.error!, style: const TextStyle(color: Colors.red)),
                                      TextButton(onPressed: _fetchData, child: const Text('Coba Lagi'))
                                    ],
                                  ),
                                )
                          : productProvider.categories.isEmpty
                              ? const Center(child: Text('Kategori tidak tersedia'))
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: productProvider.categories.map((cat) {
                                    return _buildCategoryItem(
                                      context,
                                      cat.name,
                                      cat.iconUrl ?? 'assets/images/wanita_icons.png',
                                      const Color(0xFF7F0909),
                                    );
                                  }).toList(),
                                ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                // Popular Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Populer', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: maroonColor)),
                      const SizedBox(height: 15),
                      productProvider.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : productProvider.products.isEmpty
                              ? const Center(child: Text('Tidak ada produk populer'))
                              : GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.75),
                                  itemCount: productProvider.products.length,
                                  itemBuilder: (context, index) => _buildProductItem(productProvider.products, index),
                                ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          height: 70,
          decoration: const BoxDecoration(color: maroonColor),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen())),
                child: const Icon(Icons.home, color: Colors.white, size: 28),
              ),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchScreen())).then((_) => _refreshCartCount()), 
                child: Icon(Icons.search, color: Colors.white.withOpacity(0.5), size: 28)
              ),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen())).then((_) => _refreshCartCount()),
                child: const Icon(Icons.notifications_none, color: Colors.white, size: 28),
              ),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())).then((_) => _refreshCartCount()),
                child: Icon(Icons.person_outline, color: Colors.white.withOpacity(0.5), size: 28),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, String label, String imagePath, Color color) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SearchResultScreen(searchQuery: label))).then((_) => _refreshCartCount()),
      child: Column(
        children: [
          Container(height: 60, width: 60, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color, shape: BoxShape.circle), child: Image.asset(imagePath, fit: BoxFit.contain)),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  String _primaryImageUrl(ProductEntity product) {
    return product.primaryImageUrl;
  }

  Widget _buildProductItem(List<ProductEntity> products, int index) {
    final product = products[index];
    final String imageUrl = _primaryImageUrl(product);
    final String priceStr = product.price.toStringAsFixed(0);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProductDetailScreen(product: {
          'id': product.id.toString(),
          'name': product.name,
          'price': priceStr,
          'image': imageUrl,
          'description': product.description ?? '',
          'stock': product.stock.toString(),
        })),
      ).then((_) => _refreshCartCount()),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), 
              image: DecorationImage(image: AssetImage(imageUrl), fit: BoxFit.cover)
            )
          ),
          Positioned(
            top: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), 
              decoration: BoxDecoration(
                color: const Color(0xFFE5989B).withOpacity(0.8), 
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(5), topRight: Radius.circular(10))
              ), 
              child: Text(index % 2 == 0 ? '-50%' : '-60%', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))
            ),
          ),
        ],
      ),
    );
  }
}
