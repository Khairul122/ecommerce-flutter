import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';

/// Sumber data lokal (secure storage) untuk data user terakhir. Token
/// disimpan terpisah lewat [TokenStorage] di core (dipakai bersama ApiService).
class AuthLocalDataSource {
  final FlutterSecureStorage _storage;
  AuthLocalDataSource(this._storage);

  static const _userKey = 'ootday_owner_user';

  Future<UserModel?> readUser() async {
    final raw = await _storage.read(key: _userKey);
    if (raw == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUser(Map<String, dynamic> userJson) {
    return _storage.write(key: _userKey, value: jsonEncode(userJson));
  }

  Future<void> clear() => _storage.delete(key: _userKey);
}
