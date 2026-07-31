import 'dart:io';

import '../../../../core/usecase.dart';
import '../entities/store_entity.dart';
import '../repositories/store_repository.dart';

class GetStoreUseCase extends UseCase<StoreEntity, NoParams> {
  final StoreRepository repository;
  GetStoreUseCase(this.repository);

  @override
  Future<StoreEntity> call(NoParams params) => repository.getStore();
}

class UpdateStoreParams {
  final String? storeName;
  final String? description;
  final String? address;
  final String? phone;
  final String? logoUrl;
  const UpdateStoreParams({
    this.storeName,
    this.description,
    this.address,
    this.phone,
    this.logoUrl,
  });
}

class UpdateStoreUseCase extends UseCase<StoreEntity, UpdateStoreParams> {
  final StoreRepository repository;
  UpdateStoreUseCase(this.repository);

  @override
  Future<StoreEntity> call(UpdateStoreParams params) => repository.updateStore(
        storeName: params.storeName,
        description: params.description,
        address: params.address,
        phone: params.phone,
        logoUrl: params.logoUrl,
      );
}

class UploadLogoUseCase extends UseCase<String, File> {
  final StoreRepository repository;
  UploadLogoUseCase(this.repository);

  @override
  Future<String> call(File params) => repository.uploadLogo(params);
}

class RemoveLogoUseCase extends UseCase<void, NoParams> {
  final StoreRepository repository;
  RemoveLogoUseCase(this.repository);

  @override
  Future<void> call(NoParams params) => repository.removeLogo();
}
