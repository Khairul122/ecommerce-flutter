import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';

/// Sumber data lokal (secure storage) untuk data user terakhir, supaya sesi
/// tetap ada setelah aplikasi ditutup. Token disimpan terpisah lewat
/// [TokenStorage] di core (dipakai bersama oleh ApiService).
class AuthLocalDataSource {
  final FlutterSecureStorage _storage;
  AuthLocalDataSource(this._storage);

  static const _userKey = 'ootday_auth_user';

  Future<UserModel?> readUser() async {
    final userJson = await _storage.read(key: _userKey);
    if (userJson == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUser(Map<String, dynamic> userJson) {
    return _storage.write(key: _userKey, value: jsonEncode(userJson));
  }

  Future<void> clear() => _storage.delete(key: _userKey);
}
