import '../../../../core/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RestoreSessionUseCase extends UseCase<UserEntity?, NoParams> {
  final AuthRepository repository;
  RestoreSessionUseCase(this.repository);

  @override
  Future<UserEntity?> call(NoParams params) => repository.restoreSession();
}

class RegisterOwnerParams {
  final String name;
  final String email;
  final String password;
  final String phone;
  final String storeName;
  const RegisterOwnerParams({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.storeName,
  });
}

class RegisterOwnerUseCase extends UseCase<UserEntity, RegisterOwnerParams> {
  final AuthRepository repository;
  RegisterOwnerUseCase(this.repository);

  @override
  Future<UserEntity> call(RegisterOwnerParams params) => repository.registerOwner(
        name: params.name,
        email: params.email,
        password: params.password,
        phone: params.phone,
        storeName: params.storeName,
      );
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

class GetMeUseCase extends UseCase<UserEntity, NoParams> {
  final AuthRepository repository;
  GetMeUseCase(this.repository);

  @override
  Future<UserEntity> call(NoParams params) => repository.getMe();
}

class UpdatePasswordParams {
  final String currentPassword;
  final String newPassword;
  const UpdatePasswordParams({
    required this.currentPassword,
    required this.newPassword,
  });
}

class UpdatePasswordUseCase extends UseCase<void, UpdatePasswordParams> {
  final AuthRepository repository;
  UpdatePasswordUseCase(this.repository);

  @override
  Future<void> call(UpdatePasswordParams params) => repository.updatePassword(
        currentPassword: params.currentPassword,
        newPassword: params.newPassword,
      );
}

class UpdateProfileParams {
  final String? name;
  final String? phone;
  const UpdateProfileParams({this.name, this.phone});
}

class UpdateProfileUseCase extends UseCase<UserEntity, UpdateProfileParams> {
  final AuthRepository repository;
  UpdateProfileUseCase(this.repository);

  @override
  Future<UserEntity> call(UpdateProfileParams params) =>
      repository.updateProfile(name: params.name, phone: params.phone);
}

class ForgotPasswordUseCase extends UseCase<void, String> {
  final AuthRepository repository;
  ForgotPasswordUseCase(this.repository);

  @override
  Future<void> call(String email) => repository.forgotPassword(email);
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
