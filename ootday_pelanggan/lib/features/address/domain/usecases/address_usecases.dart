import '../../../../core/usecase.dart';
import '../entities/address_entity.dart';
import '../entities/region_entity.dart';
import '../repositories/address_repository.dart';

class GetAddressesUseCase extends UseCase<List<AddressEntity>, NoParams> {
  final AddressRepository repository;
  GetAddressesUseCase(this.repository);

  @override
  Future<List<AddressEntity>> call(NoParams params) => repository.getAddresses();
}

class GetProvincesUseCase extends UseCase<List<ProvinceEntity>, NoParams> {
  final AddressRepository repository;
  GetProvincesUseCase(this.repository);

  @override
  Future<List<ProvinceEntity>> call(NoParams params) => repository.getProvinces();
}

class GetCitiesUseCase extends UseCase<List<CityEntity>, int> {
  final AddressRepository repository;
  GetCitiesUseCase(this.repository);

  @override
  Future<List<CityEntity>> call(int provinceId) => repository.getCities(provinceId);
}

class AddAddressParams {
  final String name;
  final String phone;
  final int? provinceId;
  final String? provinceName;
  final int? cityId;
  final String? cityName;
  final String fullAddress;
  final bool isMain;
  const AddAddressParams({
    required this.name,
    required this.phone,
    this.provinceId,
    this.provinceName,
    this.cityId,
    this.cityName,
    required this.fullAddress,
    required this.isMain,
  });
}

class AddAddressUseCase extends UseCase<void, AddAddressParams> {
  final AddressRepository repository;
  AddAddressUseCase(this.repository);

  @override
  Future<void> call(AddAddressParams params) => repository.addAddress(
        name: params.name,
        phone: params.phone,
        provinceId: params.provinceId,
        provinceName: params.provinceName,
        cityId: params.cityId,
        cityName: params.cityName,
        fullAddress: params.fullAddress,
        isMain: params.isMain,
      );
}

class UpdateAddressParams {
  final String id;
  final String name;
  final String phone;
  final int? provinceId;
  final String? provinceName;
  final int? cityId;
  final String? cityName;
  final String fullAddress;
  final bool isMain;
  const UpdateAddressParams({
    required this.id,
    required this.name,
    required this.phone,
    this.provinceId,
    this.provinceName,
    this.cityId,
    this.cityName,
    required this.fullAddress,
    required this.isMain,
  });
}

class UpdateAddressUseCase extends UseCase<void, UpdateAddressParams> {
  final AddressRepository repository;
  UpdateAddressUseCase(this.repository);

  @override
  Future<void> call(UpdateAddressParams params) => repository.updateAddress(
        id: params.id,
        name: params.name,
        phone: params.phone,
        provinceId: params.provinceId,
        provinceName: params.provinceName,
        cityId: params.cityId,
        cityName: params.cityName,
        fullAddress: params.fullAddress,
        isMain: params.isMain,
      );
}

class DeleteAddressUseCase extends UseCase<void, String> {
  final AddressRepository repository;
  DeleteAddressUseCase(this.repository);

  @override
  Future<void> call(String id) => repository.deleteAddress(id);
}

class SetMainAddressUseCase extends UseCase<void, String> {
  final AddressRepository repository;
  SetMainAddressUseCase(this.repository);

  @override
  Future<void> call(String id) => repository.setMain(id);
}
