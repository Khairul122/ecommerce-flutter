import '../../../../core/services/api_service.dart';
import '../models/user_model.dart';

/// Hasil auth mentah dari server: token Sanctum + data user.
class AuthResult {
  final String token;
  final UserModel user;
  const AuthResult({required this.token, required this.user});
}

/// Sumber data remote (REST API Laravel) untuk fitur auth. Tidak menyimpan
/// state apa pun — murni pemanggilan endpoint dan parsing response.
class AuthRemoteDataSource {
  final ApiService _api;
  AuthRemoteDataSource(this._api);

  AuthResult _parseAuthResult(Map<String, dynamic> result) {
    final data = (result['data'] ?? result) as Map<String, dynamic>;
    final token = data['token']?.toString();
    final userJson = data['user'];
    if (token == null || token.isEmpty || userJson is! Map<String, dynamic>) {
      throw Exception('Respons server tidak valid, silakan coba lagi.');
    }
    return AuthResult(token: token, user: UserModel.fromJson(userJson));
  }

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final result = await _api.post(
      '/register',
      {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
        'phone': (phone == null || phone.isEmpty) ? null : phone,
        'role': 'pelanggan',
      },
      withAuth: false,
    );
    return _parseAuthResult(result);
  }

  Future<AuthResult> login(String email, String password) async {
    final result = await _api.post(
      '/login',
      {'email': email, 'password': password},
      withAuth: false,
    );
    return _parseAuthResult(result);
  }

  Future<UserModel> getMe() async {
    final result = await _api.get('/me');
    final data = (result['data'] ?? result) as Map<String, dynamic>;
    final userJson = (data['user'] ?? data) as Map<String, dynamic>;
    return UserModel.fromJson(userJson);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _api.put('/me/password', {
      'current_password': currentPassword,
      'new_password': newPassword,
    });
  }

  Future<void> forgotPassword(String email) {
    return _api.post('/forgot-password', {'email': email}, withAuth: false);
  }

  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
  }) {
    return _api.post(
      '/reset-password',
      {
        'email': email,
        'token': token,
        'password': password,
        'password_confirmation': password,
      },
      withAuth: false,
    );
  }

  Future<void> deleteAccount() => _api.delete('/me');

  Future<void> logout() => _api.post('/logout', {});
}
