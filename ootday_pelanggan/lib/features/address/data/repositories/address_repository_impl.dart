import '../../domain/entities/address_entity.dart';
import '../../domain/entities/region_entity.dart';
import '../../domain/repositories/address_repository.dart';
import '../datasources/address_remote_data_source.dart';

class AddressRepositoryImpl implements AddressRepository {
  final AddressRemoteDataSource remote;

  AddressRepositoryImpl({required this.remote});

  @override
  Future<List<AddressEntity>> getAddresses() => remote.getAddresses();

  @override
  Future<List<ProvinceEntity>> getProvinces() => remote.getProvinces();

  @override
  Future<List<CityEntity>> getCities(int provinceId) => remote.getCities(provinceId);

  @override
  Future<void> addAddress({
    required String name,
    required String phone,
    int? provinceId,
    String? provinceName,
    int? cityId,
    String? cityName,
    required String fullAddress,
    required bool isMain,
    int? districtId,
    String? districtName,
    String? cityName,
    String? provinceName,
    String? postalCode,
  }) {
    return remote.addAddress(
      name: name,
      phone: phone,
      provinceId: provinceId,
      provinceName: provinceName,
      cityId: cityId,
      cityName: cityName,
      fullAddress: fullAddress,
      isMain: isMain,
      districtId: districtId,
      districtName: districtName,
      cityName: cityName,
      provinceName: provinceName,
      postalCode: postalCode,
    );
  }

  @override
  Future<void> updateAddress({
    required String id,
    required String name,
    required String phone,
    int? provinceId,
    String? provinceName,
    int? cityId,
    String? cityName,
    required String fullAddress,
    required bool isMain,
    int? districtId,
    String? districtName,
    String? cityName,
    String? provinceName,
    String? postalCode,
  }) {
    return remote.updateAddress(
      id: id,
      name: name,
      phone: phone,
      provinceId: provinceId,
      provinceName: provinceName,
      cityId: cityId,
      cityName: cityName,
      fullAddress: fullAddress,
      isMain: isMain,
      districtId: districtId,
      districtName: districtName,
      cityName: cityName,
      provinceName: provinceName,
      postalCode: postalCode,
    );
  }

  @override
  Future<void> deleteAddress(String id) => remote.deleteAddress(id);

  @override
  Future<void> setMain(String id) => remote.setMain(id);

  @override
  Future<List<Map<String, dynamic>>> searchDestinations(String keyword) => remote.searchDestinations(keyword);
}
