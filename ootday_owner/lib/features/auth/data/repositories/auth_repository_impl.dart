import '../../../../core/services/token_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/exceptions/auth_exception.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

const _ownerRole = 'owner';

/// Implementasi [AuthRepository] untuk owner: mengoordinasikan remote data
/// source (REST API) dan local data source (secure storage), plus cache di
/// memori supaya [currentUser]/[isLoggedIn] bisa dibaca sinkron.
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

  @override
  UserEntity? get currentUser => _cachedUser;

  @override
  bool get isLoggedIn => _cachedToken != null && _cachedToken!.isNotEmpty;

  @override
  Future<UserEntity?> restoreSession() async {
    _cachedToken ??= await tokenStorage.read();
    if (_cachedToken == null || _cachedToken!.isEmpty) return null;

    _cachedUser = await local.readUser();

    try {
      final user = await getMe();
      if (user.role != _ownerRole) {
        await signOut();
        return null;
      }
      return user;
    } catch (_) {
      await _clearSession();
      return null;
    }
  }

  Future<UserEntity> _persistAuthResult(AuthResult result) async {
    _cachedToken = result.token;
    _cachedUser = result.user;
    await tokenStorage.write(result.token);
    await local.saveUser(result.user.raw);
    return result.user;
  }

  @override
  Future<UserEntity> registerOwner({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String storeName,
  }) async {
    final result = await remote.registerOwner(
      name: name,
      email: email,
      password: password,
      phone: phone,
      storeName: storeName,
    );
    return _persistAuthResult(result);
  }

  @override
  Future<UserEntity> login(String email, String password) async {
    final result = await remote.login(email, password);
    final user = await _persistAuthResult(result);

    if (user.role != _ownerRole) {
      await _clearSession();
      throw AuthException(
        'Akun ini terdaftar sebagai pelanggan. Gunakan aplikasi pelanggan.',
      );
    }

    return user;
  }

  @override
  Future<UserEntity> getMe() async {
    final user = await remote.getMe();
    _cachedUser = user;
    await local.saveUser(user.raw);
    return user;
  }

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return remote.updatePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  @override
  Future<UserEntity> updateProfile({String? name, String? phone}) async {
    final updated = await remote.updateProfile(name: name, phone: phone);
    // PUT /owner/profile hanya mengembalikan field yang berubah, jadi
    // di-merge ke cache lama supaya field lain (mis. `store`) tidak hilang.
    final mergedRaw = {...?_cachedUser?.raw, ...updated.raw};
    _cachedUser = UserModel.fromJson(mergedRaw);
    await local.saveUser(mergedRaw);
    return _cachedUser!;
  }

  @override
  Future<void> forgotPassword(String email) => remote.forgotPassword(email);

  @override
  Future<void> deleteAccount() async {
    await remote.deleteAccount();
    await _clearSession();
  }

  @override
  Future<void> signOut() async {
    try {
      await remote.logout();
    } catch (_) {
      // Token mungkin sudah tidak valid di server; tetap bersihkan sesi lokal.
    }
    await _clearSession();
  }

  Future<void> _clearSession() async {
    _cachedToken = null;
    _cachedUser = null;
    await local.clear();
    await tokenStorage.clear();
  }
}
