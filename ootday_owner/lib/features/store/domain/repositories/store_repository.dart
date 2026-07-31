import 'dart:io';

import '../entities/store_entity.dart';

/// Kontrak layer domain untuk data toko owner (endpoint `/owner/store`).
abstract class StoreRepository {
  Future<StoreEntity> getStore();

  Future<StoreEntity> updateStore({
    String? storeName,
    String? description,
    String? address,
    String? phone,
    String? logoUrl,
  });

  /// Upload file ke `POST /upload` lalu simpan URL-nya sebagai `logo_url`
  /// toko lewat `PUT /owner/store`. Return URL logo baru.
  Future<String> uploadLogo(File file);

  /// Hapus logo toko (set `logo_url` jadi string kosong).
  Future<void> removeLogo();
}
