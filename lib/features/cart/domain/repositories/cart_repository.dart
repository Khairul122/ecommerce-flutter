import '../entities/cart_item_entity.dart';

/// Kontrak layer domain untuk fitur keranjang. Implementasinya (data layer)
/// menentukan dari mana data ini datang (REST API Laravel, lihat
/// backend_laravel/API_CONTRACT.md).
abstract class CartRepository {
  Future<List<CartItemEntity>> getCartItems();

  /// Tambah varian produk ke keranjang. [variantId] wajib berasal dari data
  /// varian asli produk, bukan id produk.
  Future<CartItemEntity> addItem({required int variantId, int quantity = 1});

  /// Alur "Beli Sekarang": tambahkan item ke keranjang lalu jadikan dia
  /// satu-satunya item yang terpilih (is_selected). Ini diperlukan karena
  /// POST /orders di server membuat pesanan dari item keranjang yang
  /// is_selected=true, bukan dari daftar item yang dikirim langsung oleh
  /// aplikasi (lihat OrderController::store di backend). Mengembalikan id
  /// item keranjang yang baru dibuat.
  Future<String> buyNow({required int variantId, int quantity = 1});

  Future<void> updateQuantity(String cartItemId, int quantity);

  Future<void> updateSelection(String cartItemId, bool isSelected);

  Future<void> updateSelectAll(bool isSelected);

  Future<void> deleteItem(String cartItemId);
}
