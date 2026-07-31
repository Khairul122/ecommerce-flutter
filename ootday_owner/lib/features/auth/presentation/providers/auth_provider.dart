import 'package:flutter/foundation.dart';
import '../../../../core/usecase.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/auth_usecases.dart';

/// State autentikasi owner untuk seluruh aplikasi, dibaca lewat
/// `context.watch<AuthProvider>()` / `context.read<AuthProvider>()`.
/// Menggantikan pemanggilan `AuthService()`/`AuthService.cachedUser` langsung
/// dari widget.
class AuthProvider extends ChangeNotifier {
  final RestoreSessionUseCase restoreSessionUseCase;
  final RegisterOwnerUseCase registerOwnerUseCase;
  final LoginUseCase loginUseCase;
  final GetMeUseCase getMeUseCase;
  final UpdatePasswordUseCase updatePasswordUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final DeleteAccountUseCase deleteAccountUseCase;
  final SignOutUseCase signOutUseCase;

  AuthProvider({
    required this.restoreSessionUseCase,
    required this.registerOwnerUseCase,
    required this.loginUseCase,
    required this.getMeUseCase,
    required this.updatePasswordUseCase,
    required this.updateProfileUseCase,
    required this.forgotPasswordUseCase,
    required this.deleteAccountUseCase,
    required this.signOutUseCase,
  });

  UserEntity? _user;
  bool _sessionRestored = false;

  UserEntity? get currentUser => _user;
  bool get isLoggedIn => _user != null;
  bool get sessionRestored => _sessionRestored;

  Future<bool> restoreSession() async {
    _user = await restoreSessionUseCase(const NoParams());
    _sessionRestored = true;
    notifyListeners();
    return _user != null;
  }

  Future<UserEntity> registerOwner({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String storeName,
  }) async {
    _user = await registerOwnerUseCase(RegisterOwnerParams(
      name: name,
      email: email,
      password: password,
      phone: phone,
      storeName: storeName,
    ));
    notifyListeners();
    return _user!;
  }

  Future<UserEntity> login(String email, String password) async {
    _user = await loginUseCase(LoginParams(email: email, password: password));
    notifyListeners();
    return _user!;
  }

  Future<UserEntity> refreshMe() async {
    _user = await getMeUseCase(const NoParams());
    notifyListeners();
    return _user!;
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return updatePasswordUseCase(UpdatePasswordParams(
      currentPassword: currentPassword,
      newPassword: newPassword,
    ));
  }

  Future<UserEntity> updateProfile({String? name, String? phone}) async {
    _user = await updateProfileUseCase(UpdateProfileParams(name: name, phone: phone));
    notifyListeners();
    return _user!;
  }

  Future<void> forgotPassword(String email) => forgotPasswordUseCase(email);

  Future<void> deleteAccount() async {
    await deleteAccountUseCase(const NoParams());
    _user = null;
    notifyListeners();
  }

  Future<void> signOut() async {
    await signOutUseCase(const NoParams());
    _user = null;
    notifyListeners();
  }
}
