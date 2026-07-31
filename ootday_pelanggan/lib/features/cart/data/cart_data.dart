// cart_data.dart
//
// Menggantikan endpoint PHP lama (/cart/get.php, /cart/add.php, dst, yang
// sudah tidak ada) dengan endpoint Laravel /api/cart/* (lihat
// backend_laravel/API_CONTRACT.md). Perbaikan audit penting: sebelumnya semua
// method di sini menelan (swallow) error dan diam-diam mengembalikan
// list kosong / tidak melakukan apa-apa, sehingga UI menampilkan SnackBar
// "berhasil" palsu walau request sebenarnya gagal. Sekarang error dilempar
// (rethrow) supaya pemanggil (UI) bisa menampilkan pesan error yang jujur.
import '../../../core/services/api_service.dart';

class CartData {
  static final ApiService _api = ApiService();

  /// Ambil semua item keranjang milik user yang sedang login.
  static Future<List<Map<String, dynamic>>> getCartItems() async {
    final result = await _api.get('/cart');
    final List rawItems = result['data'] ?? [];
    return rawItems.map((item) => _mapCartItem(item as Map<String, dynamic>)).toList();
  }

  static Map<String, dynamic> _mapCartItem(Map<String, dynamic> item) {
    final variant = (item['variant'] as Map<String, dynamic>?) ?? {};
    final product = (variant['product'] as Map<String, dynamic>?) ?? {};
    final images = (product['images'] as List?) ?? [];

    String image = 'assets/images/Produk_1.png';
    if (images.isNotEmpty) {
      final primary = images.firstWhere(
        (img) => img is Map && img['is_primary'] == true,
        orElse: () => images.first,
      );
      if (primary is Map && primary['image_url'] != null) {
        image = primary['image_url'].toString();
      }
    }

    final double priceVal =
        double.tryParse((variant['price'] ?? product['price'] ?? 0).toString()) ?? 0;
    final dynamic qtyRaw = item['quantity'];
    final int quantity = qtyRaw is int ? qtyRaw : int.tryParse(qtyRaw.toString()) ?? 1;

    return {
      'id': item['id'].toString(),
      'variant_id': (item['variant_id'] ?? variant['id'] ?? '').toString(),
      'product_id': (variant['product_id'] ?? product['id'] ?? '').toString(),
      'name': product['name'] ?? '',
      'desc': 'Warna: ${variant['color'] ?? 'Default'}, Ukuran: ${variant['size'] ?? 'M'}',
      'price': priceVal.round(),
      'quantity': quantity,
      'selected': item['is_selected'] == true || item['is_selected'] == 1,
      'image': image,
    };
  }

  /// Tambah varian produk ke keranjang. [variantId] wajib berasal dari data
  /// varian asli produk (lihat product_detail_screen.dart), bukan id produk.
  static Future<Map<String, dynamic>> addItem({
    required int variantId,
    int quantity = 1,
  }) async {
    final result = await _api.post('/cart', {
      'variant_id': variantId,
      'quantity': quantity,
    });
    return Map<String, dynamic>.from(result['data'] ?? {});
  }

  /// Alur "Beli Sekarang": tambahkan item ke keranjang lalu jadikan dia
  /// satu-satunya item yang terpilih (is_selected). Ini diperlukan karena
  /// POST /orders di server membuat pesanan dari item keranjang yang
  /// is_selected=true, bukan dari daftar item yang dikirim langsung oleh
  /// aplikasi (lihat OrderController::store di backend).
  static Future<String> buyNow({required int variantId, int quantity = 1}) async {
    final created = await addItem(variantId: variantId, quantity: quantity);
    final newId = created['id'].toString();
    await updateSelectAll(false);
    await updateSelection(newId, true);
    return newId;
  }

  static Future<void> updateQuantity(String cartItemId, int quantity) async {
    await _api.put('/cart/$cartItemId', {'quantity': quantity});
  }

  static Future<void> updateSelection(String cartItemId, bool isSelected) async {
    await _api.put('/cart/$cartItemId', {'is_selected': isSelected});
  }

  static Future<void> updateSelectAll(bool isSelected) async {
    await _api.post('/cart/select-all', {'is_selected': isSelected});
  }

  static Future<void> deleteItem(String cartItemId) async {
    await _api.delete('/cart/$cartItemId');
  }
}
