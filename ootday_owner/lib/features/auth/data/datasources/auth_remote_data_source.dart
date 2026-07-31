import '../../../../core/services/api_service.dart';
import '../../domain/exceptions/auth_exception.dart';
import '../models/user_model.dart';

class AuthResult {
  final String token;
  final UserModel user;
  const AuthResult({required this.token, required this.user});
}

/// Sumber data remote (REST API Laravel) untuk fitur auth owner.
class AuthRemoteDataSource {
  final ApiService _api;
  AuthRemoteDataSource(this._api);

  AuthResult _parseAuthResult(Map<String, dynamic> res) {
    final data = res['data'] as Map<String, dynamic>? ?? {};
    final token = data['token'] as String?;
    final userJson = data['user'] as Map<String, dynamic>?;
    if (token == null || userJson == null) {
      throw AuthException('Respons login/registrasi tidak lengkap');
    }
    return AuthResult(token: token, user: UserModel.fromJson(userJson));
  }

  Future<AuthResult> registerOwner({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String storeName,
  }) async {
    final res = await _api.post('/register', {
      'name': name,
      'email': email,
      'password': password,
      if (phone.isNotEmpty) 'phone': phone,
      'role': 'owner',
      'store_name': storeName,
    }, auth: false);
    return _parseAuthResult(res);
  }

  Future<AuthResult> login(String email, String password) async {
    final res = await _api.post('/login', {
      'email': email,
      'password': password,
    }, auth: false);
    return _parseAuthResult(res);
  }

  Future<UserModel> getMe() async {
    final res = await _api.get('/me');
    final userJson = (res['data'] as Map<String, dynamic>)['user'] as Map<String, dynamic>;
    return UserModel.fromJson(userJson);
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _api.put('/me/password', {
      'current_password': currentPassword,
      'new_password': newPassword,
    });
  }

  Future<UserModel> updateProfile({String? name, String? phone}) async {
    final res = await _api.put('/owner/profile', {
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
    });
    return UserModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<void> forgotPassword(String email) {
    return _api.post('/forgot-password', {'email': email}, auth: false);
  }

  Future<void> deleteAccount() => _api.delete('/me');

  Future<void> logout() => _api.post('/logout', {});
}
