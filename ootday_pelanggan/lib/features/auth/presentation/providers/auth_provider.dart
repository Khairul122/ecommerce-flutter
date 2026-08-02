import 'package:flutter/foundation.dart';
import '../../../../core/usecase.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/auth_usecases.dart';

/// State autentikasi untuk seluruh aplikasi, dibaca lewat
/// `context.watch<AuthProvider>()` / `context.read<AuthProvider>()`.
/// Menggantikan pemanggilan `AuthService()` langsung dari widget.
class AuthProvider extends ChangeNotifier {
  final LoadSessionUseCase loadSessionUseCase;
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final RefreshMeUseCase refreshMeUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final ChangePasswordUseCase changePasswordUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final DeleteAccountUseCase deleteAccountUseCase;
  final SignOutUseCase signOutUseCase;

  AuthProvider({
    required this.loadSessionUseCase,
    required this.loginUseCase,
    required this.registerUseCase,
    required this.refreshMeUseCase,
    required this.updateProfileUseCase,
    required this.changePasswordUseCase,
    required this.forgotPasswordUseCase,
    required this.resetPasswordUseCase,
    required this.deleteAccountUseCase,
    required this.signOutUseCase,
  });

  UserEntity? _user;
  bool _sessionLoaded = false;

  UserEntity? get currentUser => _user;
  bool get isLoggedIn => _user != null;
  bool get sessionLoaded => _sessionLoaded;

  Future<UserEntity?> loadSession() async {
    _user = await loadSessionUseCase(const NoParams());
    _sessionLoaded = true;
    notifyListeners();
    return _user;
  }

  Future<UserEntity> login(String email, String password) async {
    _user = await loginUseCase(LoginParams(email: email, password: password));
    notifyListeners();
    return _user!;
  }

  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    _user = await registerUseCase(RegisterParams(
      name: name,
      email: email,
      password: password,
      phone: phone,
    ));
    notifyListeners();
    return _user!;
  }

  Future<UserEntity> refreshMe() async {
    _user = await refreshMeUseCase(const NoParams());
    notifyListeners();
    return _user!;
  }

  Future<UserEntity> updateProfile({required String name, String? phone}) async {
    _user = await updateProfileUseCase(UpdateProfileParams(name: name, phone: phone));
    notifyListeners();
    return _user!;
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return changePasswordUseCase(ChangePasswordParams(
      currentPassword: currentPassword,
      newPassword: newPassword,
    ));
  }

  Future<void> forgotPassword(String email) => forgotPasswordUseCase(email);

  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
  }) {
    return resetPasswordUseCase(ResetPasswordParams(
      email: email,
      token: token,
      password: password,
    ));
  }

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
