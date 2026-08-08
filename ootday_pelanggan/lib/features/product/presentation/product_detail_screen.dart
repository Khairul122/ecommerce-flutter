import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../cart/presentation/cart_screen.dart';
import '../../cart/presentation/providers/cart_provider.dart';
import '../../checkout/presentation/checkout_screen.dart';
import '../../cart/data/cart_data.dart';
import '../../chat/presentation/chat_list_screen.dart';
import '../../chat/presentation/chat_detail_screen.dart';
import '../../../core/services/api_service.dart';
import 'providers/product_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, String> product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String _selectedSize = 'M';
  String _selectedColor = 'Default';
  int _selectedColorIndex = 0;
  int _currentPage = 0;
  int _quantity = 1;
  int _cartCount = 0;
  final PageController _pageController = PageController();

  List<String> _images = [];
  List<String> _sizes = [];
  List<String> _colors = [];
  // Daftar varian asli dari server (id, size, color, stock, price), dibutuhkan
  // supaya CartData.addItem/buyNow bisa mengirim variant_id yang benar ke
  // POST /api/cart, bukan sekadar nama ukuran/warna sebagai teks.
  List<Map<String, dynamic>> _variants = [];
  // Foto per warna (dari product_variants.image_url), dipakai supaya klik
  // warna benar-benar menampilkan foto varian itu, bukan indeks acak dari
  // daftar foto produk umum.
  Map<String, String> _colorImages = {};
  Map<String, int> _colorPageIndex = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProductDetails();
    _refreshCartCount();
  }

  Future<void> _refreshCartCount() async {
    try {
      final cartItems = await CartData.getCartItems();
      final count = cartItems.fold<int>(0, (sum, item) => sum + (item['quantity'] as int));
      if (mounted) {
        setState(() {
          _cartCount = count;
        });
      }
    } catch (e) {
      debugPrint('Error fetching cart count: $e');
    }
  }

  Future<void> _contactSeller() async {
    final storeId = widget.product['store_id'];
    final storeName = widget.product['store_name'] ?? 'Toko';
    if (storeId == null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatListScreen()));
      return;
    }
    try {
      final result = await ApiService().post('/conversations', {'store_id': int.parse(storeId)});
      final conversation = Map<String, dynamic>.from(result['data'] ?? {});
      if (!mounted) return;
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuka chat: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadProductDetails() async {
    try {
      final String? productId = widget.product['id'];
      if (productId == null) {
        setState(() {
          _images = [widget.product['image'] ?? 'assets/images/Produk_1.png'];
          _sizes = ['S', 'M', 'L', 'XL'];
          _colors = ['Default'];
          _isLoading = false;
        });
        return;
      }

      final int? parsedId = int.tryParse(productId);
      final product = parsedId == null
          ? null
          : await context.read<ProductProvider>().fetchProduct(parsedId);

      if (product == null) {
        if (mounted) {
          setState(() {
            _images = [widget.product['image'] ?? 'assets/images/Produk_1.png'];
            _sizes = ['S', 'M', 'L', 'XL'];
            _colors = ['Default'];
            _isLoading = false;
          });
        }
        return;
      }

      final List<String> loadedImages = product.images
          .map((img) => img.imageUrl)
          .where((url) => url.isNotEmpty)
          .toList();
      if (loadedImages.isEmpty) {
        loadedImages.add(widget.product['image'] ?? 'assets/images/Produk_1.png');
      }

      final List<Map<String, dynamic>> loadedVariants = product.variants
          .map((v) => {
                'id': v.id,
                'size': v.size,
                'color': v.color,
                'stock': v.stock,
                'price': v.price,
                'image_url': v.imageUrl,
              })
          .toList();

      final Set<String> loadedSizes = {};
      final Set<String> loadedColors = {};
      final Map<String, String> colorImages = {};
      for (var row in loadedVariants) {
        if (row['size'] != null) loadedSizes.add(row['size'].toString());
        if (row['color'] != null) loadedColors.add(row['color'].toString());
        final color = row['color']?.toString();
        final imgUrl = row['image_url']?.toString();
        if (color != null && imgUrl != null && imgUrl.isNotEmpty && !colorImages.containsKey(color)) {
          colorImages[color] = imgUrl;
        }
      }

      // Gabungkan foto produk umum dengan foto khusus per-warna (kalau ada),
      // supaya carousel utama juga bisa di-swipe ke foto varian tersebut.
      final List<String> combinedImages = [...loadedImages];
      final Map<String, int> colorPageIndex = {};
      for (final entry in colorImages.entries) {
        int index = combinedImages.indexOf(entry.value);
        if (index == -1) {
          combinedImages.add(entry.value);
          index = combinedImages.length - 1;
        }
        colorPageIndex[entry.key] = index;
      }

      if (mounted) {
        setState(() {
          _images = combinedImages;
          _variants = loadedVariants;
          _colorImages = colorImages;
          _colorPageIndex = colorPageIndex;
          _sizes = loadedSizes.isNotEmpty ? loadedSizes.toList() : ['S', 'M', 'L', 'XL'];
          _colors = loadedColors.isNotEmpty ? loadedColors.toList() : ['Default'];

          if (_sizes.isNotEmpty) {
            _selectedSize = _sizes.contains('M') ? 'M' : _sizes.first;
          }
          if (_colors.isNotEmpty) {
            _selectedColor = _colors.first;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading product details: $e');
      if (mounted) {
        setState(() {
          _images = [widget.product['image'] ?? 'assets/images/Produk_1.png'];
          _sizes = ['S', 'M', 'L', 'XL'];
          _colors = ['Default'];
          _isLoading = false;
        });
      }
    }
  }

  /// Cari id varian server yang cocok dengan ukuran & warna yang sedang
  /// dipilih user. Dipakai supaya "Tambah ke Keranjang"/"Beli Sekarang"
  /// mengirim variant_id yang valid ke POST /api/cart.
  Map<String, dynamic>? _resolveSelectedVariant() {
    if (_variants.isEmpty) return null;
    try {
      return _variants.firstWhere(
        (v) => (v['size']?.toString() == _selectedSize) && (v['color']?.toString() == _selectedColor),
      );
    } catch (_) {
      return null;
    }
  }

  int? _resolveSelectedVariantId() {
    final v = _resolveSelectedVariant();
    if (v == null) {
      if (_variants.isNotEmpty) {
        final id = _variants.first['id'];
        return id is int ? id : int.tryParse(id.toString());
      }
      return null;
    }
    final id = v['id'];
    if (id == null) return null;
    return id is int ? id : int.tryParse(id.toString());
  }

  int _getSelectedVariantStock() {
    final v = _resolveSelectedVariant();
    if (v != null && v['stock'] != null) {
      return int.tryParse(v['stock'].toString()) ?? 0;
    }
    final pStock = widget.product['stock'];
    return pStock != null ? (int.tryParse(pStock.toString()) ?? 100) : 100;
  }

  void _showVariantSheet({required String buttonText}) {
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            const Color maroonColor = Color(0xFF5D1A1A);
            const Color lightBg = Color(0xFFF8F3F3);

            final currentStock = _getSelectedVariantStock();

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: lightBg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Column(
                children: [
                  // 1. Header Section
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            image: DecorationImage(
                              image: AssetImage(widget.product['image'] ?? 'assets/images/Produk_1.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Rp ${widget.product['price']}',
                                    style: GoogleFonts.outfit(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black,
                                    ),
                                  ),
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(Icons.close, color: Colors.black),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Stok: $currentStock',
                                style: GoogleFonts.outfit(
                                  color: currentStock > 0 ? Colors.green.shade700 : Colors.red, 
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // 2. Content Sections
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 15),
                          Text(
                            'Warna', 
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: _colors.map((c) {
                              Color colorValue = Colors.grey;
                              if (c.toLowerCase() == 'hitam') colorValue = Colors.black;
                              else if (c.toLowerCase() == 'putih') colorValue = Colors.white;
                              else if (c.toLowerCase() == 'denim') colorValue = const Color(0xFF4B6584);
                              else if (c.toLowerCase() == 'coksu') colorValue = const Color(0xFFD2B48C);
                              
                              bool isSel = _selectedColor == c;
                              return GestureDetector(
                                onTap: () => setModalState(() {
                                  _selectedColor = c;
                                }),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: isSel ? maroonColor : Colors.grey[400]!, width: 1.5),
                                    borderRadius: BorderRadius.circular(10),
                                    color: isSel ? Colors.white : Colors.transparent,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 15,
                                        height: 15,
                                        decoration: BoxDecoration(
                                          color: colorValue,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.grey.withValues(alpha: 0.3), width: 1),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        c, 
                                        style: GoogleFonts.outfit(
                                          color: isSel ? maroonColor : Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 25),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Ukuran', 
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                'Tabel Ukuran >', 
                                style: GoogleFonts.outfit(
                                  color: Colors.black54, 
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: _sizes.map((s) {
                              bool isSel = _selectedSize == s;
                              return GestureDetector(
                                onTap: () => setModalState(() => _selectedSize = s),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 12),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: isSel ? maroonColor : Colors.grey[400]!, width: 1.5),
                                    borderRadius: BorderRadius.circular(10),
                                    color: isSel ? Colors.white : Colors.transparent,
                                  ),
                                  child: Text(
                                    s, 
                                    style: GoogleFonts.outfit(
                                      color: isSel ? maroonColor : Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 25),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Jumlah', 
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black,
                                  fontSize: 15,
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[400]!, width: 1.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove, size: 18, color: Colors.black),
                                      onPressed: _quantity > 1
                                          ? () => setModalState(() => _quantity--)
                                          : null,
                                    ),
                                    Text(
                                      '$_quantity', 
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add, size: 18, color: Colors.black),
                                      onPressed: () {
                                        if (_quantity < currentStock) {
                                          setModalState(() => _quantity++);
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Jumlah tidak boleh melebihi sisa stok ($currentStock)')),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),

                  // 3. Confirm Button (Dynamic Action)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: ElevatedButton(
                      onPressed: (isSubmitting || currentStock <= 0)
                          ? null
                          : () async {
                              final selectedVar = _resolveSelectedVariant();
                              if (_variants.isNotEmpty && selectedVar == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Silakan pilih varian terlebih dahulu')),
                                );
                                return;
                              }

                              final variantId = _resolveSelectedVariantId();
                              if (variantId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Varian produk tidak tersedia')),
                                );
                                return;
                              }

                              if (currentStock <= 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Stok produk habis')),
                                );
                                return;
                              }

                              if (_quantity > currentStock) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Jumlah melebihi stok yang tersedia (Sisa: $currentStock)')),
                                );
                                return;
                              }

                              setModalState(() => isSubmitting = true);
                              try {
                                if (buttonText == 'Beli Sekarang') {
                                  await context.read<CartProvider>().buyNow(variantId: variantId, quantity: _quantity);
                                  if (!context.mounted) return;
                                  Navigator.pop(context); // Pop sheet
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const CheckoutScreen()),
                                  );
                                } else {
                                  await context.read<CartProvider>().addItem(variantId: variantId, quantity: _quantity);
                                  await _refreshCartCount();
                                  if (!context.mounted) return;
                                  Navigator.pop(context); // Pop sheet
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Berhasil ditambahkan ke keranjang')),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Gagal memproses: $e')),
                                  );
                                }
                              } finally {
                                if (context.mounted) {
                                  setModalState(() => isSubmitting = false);
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: maroonColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
                      ),
                      child: isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              currentStock <= 0 ? 'Stok Habis' : (buttonText == 'Beli Sekarang' ? 'Beli Sekarang' : 'Tambah ke Keranjang'),
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    const Color maroonColor = Color(0xFF5D1A1A);
    const Color lightBg = Color(0xFFF3F3F3);

    String priceString = widget.product['price'] ?? '0';
    String formattedPrice = 'Rp ${priceString.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Carousel Section
                  Stack(
                    children: [
                      SizedBox(
                        height: 450,
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) => setState(() => _currentPage = index),
                          itemCount: _images.length,
                          itemBuilder: (context, index) {
                            final String imgPath = _images[index];
                            final bool isNetwork = imgPath.startsWith('http://') || imgPath.startsWith('https://');
                            return Hero(
                              tag: index == 0 ? (widget.product['id'] ?? 'product_${widget.product['name']}') : 'img_$index',
                              child: isNetwork
                                  ? Image.network(
                                      imgPath,
                                      width: double.infinity,
                                      height: 450,
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) => Image.asset('assets/images/Produk_1.png', width: double.infinity, height: 450, fit: BoxFit.cover),
                                    )
                                  : Image.asset(imgPath, width: double.infinity, height: 450, fit: BoxFit.cover),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), borderRadius: BorderRadius.circular(15)),
                          child: Text('${_currentPage + 1}/${_images.length}', style: GoogleFonts.outfit(color: Colors.white, fontSize: 12)),
                        ),
                      ),
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildCircleButton(Icons.arrow_back, () => Navigator.pop(context)),
                              Row(
                                children: [
                                  _buildCircleButton(Icons.share_outlined, () {}),
                                  const SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const CartScreen()),
                                    ).then((_) => _refreshCartCount()),
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle),
                                          child: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 20),
                                        ),
                                        if (_cartCount > 0)
                                          Positioned(
                                            right: -2,
                                            top: -2,
                                            child: Container(
                                              padding: const EdgeInsets.all(3),
                                              decoration: const BoxDecoration(color: Color(0xFFB01D1D), shape: BoxShape.circle),
                                              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                              child: Text(
                                                '$_cartCount',
                                                style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  _buildCircleButton(Icons.more_vert, () {}),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Pricing & Title
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(formattedPrice, style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
                            Row(
                              children: [
                                Text('${widget.product['sold'] ?? '120'} Terjual', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 14)),
                                const SizedBox(width: 10),
                                const Icon(Icons.favorite_border, color: Colors.black, size: 24),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Text(widget.product['name'] ?? 'Produk Ootday', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black, height: 1.3)),
                      ],
                    ),
                  ),

                  // Variant - Warna
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Warna', style: GoogleFonts.outfit(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 70,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _colors.length,
                            itemBuilder: (context, index) {
                              final color = _colors[index];
                              final bool isSel = _selectedColor == color;
                              final String thumbImg = _colorImages[color] ??
                                  (widget.product['image'] ?? 'assets/images/Produk_1.png');
                              final bool isNetThumb = thumbImg.startsWith('http://') || thumbImg.startsWith('https://');
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedColor = color;
                                    _selectedColorIndex = index;
                                    final pageIndex = _colorPageIndex[color];
                                    if (pageIndex != null) {
                                      _pageController.animateToPage(pageIndex, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                                    }
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 12),
                                  width: 70,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: isSel ? maroonColor : Colors.grey.withOpacity(0.3), width: 2),
                                    image: DecorationImage(
                                      image: isNetThumb ? NetworkImage(thumbImg) as ImageProvider : AssetImage(thumbImg),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Container(
                                    color: Colors.black45,
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    child: Text(
                                      color, 
                                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Variant - Ukuran
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ukuran', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black)),
                        const SizedBox(height: 12),
                        Row(
                          children: _sizes.map((size) {
                            bool isSelected = _selectedSize == size;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedSize = size),
                              child: Container(
                                margin: const EdgeInsets.only(right: 15),
                                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? maroonColor.withOpacity(0.1) : lightBg,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: isSelected ? maroonColor : Colors.transparent),
                                ),
                                child: Text(size, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: isSelected ? maroonColor : Colors.black87)),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Description Box
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(color: lightBg.withOpacity(0.5), borderRadius: BorderRadius.circular(15)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Deskripsi Produk', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.black)),
                          const SizedBox(height: 8),
                          Text(
                            widget.product['description'] ?? 'Koleksi fashion berkualitas tinggi dan nyaman dipakai sehari-hari.',
                            style: GoogleFonts.outfit(fontSize: 13, color: Colors.black, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
        bottomSheet: _isLoading ? null : Container(
          height: 85,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: lightBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5)),
            ],
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: _contactSeller,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: Image.asset(
                    'assets/images/icons msg.png',
                    width: 26,
                    height: 26,
                    color: const Color(0xFF5D1A1A),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(width: 1, height: 28, color: Colors.grey.withValues(alpha: 0.3)),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => _showVariantSheet(buttonText: 'Tambah ke Keranjang'),
                icon: const Icon(Icons.add_shopping_cart, size: 18, color: Color(0xFF5D1A1A)),
                label: Text('Keranjang', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF5D1A1A))),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF5D1A1A), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showVariantSheet(buttonText: 'Beli Sekarang'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5D1A1A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Beli Sekarang', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text(formattedPrice, style: GoogleFonts.outfit(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), shape: BoxShape.circle), child: Icon(icon, color: Colors.white, size: 20)));
  }
}
