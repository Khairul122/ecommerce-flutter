import '../../../../core/services/token_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

/// Implementasi [AuthRepository]: mengoordinasikan remote data source (REST
/// API) dan local data source (secure storage), plus cache di memori supaya
/// [currentUser]/[isLoggedIn] bisa dibaca sinkron oleh presentation layer.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  final AuthLocalDataSource local;
  final TokenStorage tokenStorage;

  AuthRepositoryImpl({
    required this.remote,
    required this.local,
    required this.tokenStorage,
  });

  UserModel? _cachedUser;
  String? _cachedToken;
  bool _sessionLoaded = false;

  @override
  UserEntity? get currentUser => _cachedUser;

  @override
  bool get isLoggedIn => _cachedToken != null;

  @override
  Future<UserEntity?> loadSession() async {
    if (_sessionLoaded) return _cachedUser;
    _cachedToken = await tokenStorage.read();
    _cachedUser = await local.readUser();
    _sessionLoaded = true;
    return _cachedUser;
  }

  @override
  Future<String?> getToken() async {
    if (!_sessionLoaded) await loadSession();
    return _cachedToken;
  }

  Future<UserEntity> _persistAuthResult(AuthResult result) async {
    _cachedToken = result.token;
    _cachedUser = result.user;
    _sessionLoaded = true;
    await tokenStorage.write(result.token);
    await local.saveUser(result.user.toJson());
    return result.user;
  }

  @override
  Future<UserEntity> login(String email, String password) async {
    final result = await remote.login(email, password);
    return _persistAuthResult(result);
  }

  @override
  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final result = await remote.register(
      name: name,
      email: email,
      password: password,
      phone: phone,
    );
    return _persistAuthResult(result);
  }

  @override
  Future<UserEntity> refreshMe() async {
    final user = await remote.getMe();
    _cachedUser = user;
    await local.saveUser(user.toJson());
    return user;
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return remote.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  @override
  Future<void> forgotPassword(String email) => remote.forgotPassword(email);

  @override
  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
  }) {
    return remote.resetPassword(email: email, token: token, password: password);
  }

  @override
  Future<void> deleteAccount() async {
    await remote.deleteAccount();
    await signOut();
  }

  @override
  Future<void> signOut() async {
    try {
      await remote.logout();
    } catch (_) {
      // Tetap hapus sesi lokal walau logout ke server gagal (mis. token sudah
      // kedaluwarsa/koneksi terputus) supaya user tidak terjebak.
    }
    _cachedToken = null;
    _cachedUser = null;
    await local.clear();
    await tokenStorage.clear();
  }
}
