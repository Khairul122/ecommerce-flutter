import '../../../../core/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoadSessionUseCase extends UseCase<UserEntity?, NoParams> {
  final AuthRepository repository;
  LoadSessionUseCase(this.repository);

  @override
  Future<UserEntity?> call(NoParams params) => repository.loadSession();
}

class LoginParams {
  final String email;
  final String password;
  const LoginParams({required this.email, required this.password});
}

class LoginUseCase extends UseCase<UserEntity, LoginParams> {
  final AuthRepository repository;
  LoginUseCase(this.repository);

  @override
  Future<UserEntity> call(LoginParams params) =>
      repository.login(params.email, params.password);
}

class RegisterParams {
  final String name;
  final String email;
  final String password;
  final String? phone;
  const RegisterParams({
    required this.name,
    required this.email,
    required this.password,
    this.phone,
  });
}

class RegisterUseCase extends UseCase<UserEntity, RegisterParams> {
  final AuthRepository repository;
  RegisterUseCase(this.repository);

  @override
  Future<UserEntity> call(RegisterParams params) => repository.register(
        name: params.name,
        email: params.email,
        password: params.password,
        phone: params.phone,
      );
}

class RefreshMeUseCase extends UseCase<UserEntity, NoParams> {
  final AuthRepository repository;
  RefreshMeUseCase(this.repository);

  @override
  Future<UserEntity> call(NoParams params) => repository.refreshMe();
}

class UpdateProfileParams {
  final String name;
  final String? phone;
  const UpdateProfileParams({required this.name, this.phone});
}

class UpdateProfileUseCase extends UseCase<UserEntity, UpdateProfileParams> {
  final AuthRepository repository;
  UpdateProfileUseCase(this.repository);

  @override
  Future<UserEntity> call(UpdateProfileParams params) => repository.updateProfile(
        name: params.name,
        phone: params.phone,
      );
}

class ChangePasswordParams {
  final String currentPassword;
  final String newPassword;
  const ChangePasswordParams({
    required this.currentPassword,
    required this.newPassword,
  });
}

class ChangePasswordUseCase extends UseCase<void, ChangePasswordParams> {
  final AuthRepository repository;
  ChangePasswordUseCase(this.repository);

  @override
  Future<void> call(ChangePasswordParams params) => repository.changePassword(
        currentPassword: params.currentPassword,
        newPassword: params.newPassword,
      );
}

class ForgotPasswordUseCase extends UseCase<void, String> {
  final AuthRepository repository;
  ForgotPasswordUseCase(this.repository);

  @override
  Future<void> call(String email) => repository.forgotPassword(email);
}

class ResetPasswordParams {
  final String email;
  final String token;
  final String password;
  const ResetPasswordParams({
    required this.email,
    required this.token,
    required this.password,
  });
}

class ResetPasswordUseCase extends UseCase<void, ResetPasswordParams> {
  final AuthRepository repository;
  ResetPasswordUseCase(this.repository);

  @override
  Future<void> call(ResetPasswordParams params) => repository.resetPassword(
        email: params.email,
        token: params.token,
        password: params.password,
      );
}

class DeleteAccountUseCase extends UseCase<void, NoParams> {
  final AuthRepository repository;
  DeleteAccountUseCase(this.repository);

  @override
  Future<void> call(NoParams params) => repository.deleteAccount();
}

class SignOutUseCase extends UseCase<void, NoParams> {
  final AuthRepository repository;
  SignOutUseCase(this.repository);

  @override
  Future<void> call(NoParams params) => repository.signOut();
}
