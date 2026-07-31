import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Penyimpanan token Sanctum di level core, dipakai bersama oleh [ApiService]
/// (melampirkan header Authorization) dan layer data fitur auth (menyimpan
/// token setelah login/register). Dipisah dari fitur auth supaya core tidak
/// bergantung pada layer domain/data sebuah fitur.
class TokenStorage {
  final FlutterSecureStorage _storage;
  const TokenStorage(this._storage);

  static const _tokenKey = 'ootday_owner_token';

  Future<String?> read() => _storage.read(key: _tokenKey);

  Future<void> write(String token) => _storage.write(key: _tokenKey, value: token);

  Future<void> clear() => _storage.delete(key: _tokenKey);
}
