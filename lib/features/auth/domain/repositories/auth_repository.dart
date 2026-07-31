import '../entities/user_entity.dart';

/// Kontrak layer domain untuk autentikasi owner. Implementasinya (data
/// layer) menentukan dari mana data ini datang (REST API + secure storage).
abstract class AuthRepository {
  UserEntity? get currentUser;
  bool get isLoggedIn;

  /// Memuat sesi tersimpan lalu memvalidasinya ke server (GET /me) dan
  /// memastikan rolenya owner. Return user jika sesi owner valid, null jika
  /// tidak ada sesi atau tidak valid.
  Future<UserEntity?> restoreSession();

  Future<UserEntity> registerOwner({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String storeName,
  });

  Future<UserEntity> login(String email, String password);

  Future<UserEntity> getMe();

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<UserEntity> updateProfile({String? name, String? phone});

  Future<void> forgotPassword(String email);

  Future<void> deleteAccount();

  Future<void> signOut();
}
