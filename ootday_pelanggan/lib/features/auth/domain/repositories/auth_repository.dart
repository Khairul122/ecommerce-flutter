import '../entities/user_entity.dart';

/// Kontrak layer domain untuk autentikasi. Implementasinya (data layer)
/// menentukan dari mana data ini datang (REST API + secure storage).
abstract class AuthRepository {
  UserEntity? get currentUser;
  bool get isLoggedIn;

  Future<UserEntity?> loadSession();
  Future<String?> getToken();

  Future<UserEntity> login(String email, String password);

  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  });

  Future<UserEntity> refreshMe();

  Future<UserEntity> updateProfile({
    required String name,
    String? phone,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<void> forgotPassword(String email);

  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
  });

  Future<void> deleteAccount();

  Future<void> signOut();
}
