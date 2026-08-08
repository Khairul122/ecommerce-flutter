import '../entities/address_entity.dart';
import '../entities/region_entity.dart';

abstract class AddressRepository {
  Future<List<AddressEntity>> getAddresses();

  Future<List<ProvinceEntity>> getProvinces();

  Future<List<CityEntity>> getCities(int provinceId);

  Future<void> addAddress({
    required String name,
    required String phone,
    int? provinceId,
    String? provinceName,
    int? cityId,
    String? cityName,
    required String fullAddress,
    required bool isMain,
  });

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
  });

  Future<void> deleteAddress(String id);

  Future<void> setMain(String id);
}
