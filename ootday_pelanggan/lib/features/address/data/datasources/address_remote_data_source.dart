import '../../../../core/services/api_service.dart';
import '../models/address_model.dart';
import '../models/region_model.dart';

class AddressRemoteDataSource {
  final ApiService _api;
  AddressRemoteDataSource(this._api);

  Future<List<AddressModel>> getAddresses() async {
    final result = await _api.get('/addresses');
    final List rawList = result['data'] ?? [];
    return rawList
        .map((addr) => AddressModel.fromJson(addr as Map<String, dynamic>))
        .toList();
  }

  Future<List<ProvinceModel>> getProvinces() async {
    final result = await _api.get('/shipping/provinces');
    final List rawList = result['data'] ?? [];
    return rawList
        .map((p) => ProvinceModel.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  Future<List<CityModel>> getCities(int provinceId) async {
    final result = await _api.get('/shipping/cities?province_id=$provinceId');
    final List rawList = result['data'] ?? [];
    return rawList
        .map((c) => CityModel.fromJson(c as Map<String, dynamic>))
        .toList();
  }

  Future<void> addAddress({
    required String name,
    required String phone,
    int? provinceId,
    String? provinceName,
    int? cityId,
    String? cityName,
    required String fullAddress,
    required bool isMain,
  }) {
    return _api.post('/addresses', {
      'receiver_name': name,
      'phone': phone,
      'province_id': provinceId,
      'province_name': provinceName,
      'city_id': cityId,
      'city_name': cityName,
      'full_address': fullAddress,
      'is_main': isMain,
    });
  }

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
  }) async {
    await _api.put('/addresses/$id', {
      'receiver_name': name,
      'phone': phone,
      'province_id': provinceId,
      'province_name': provinceName,
      'city_id': cityId,
      'city_name': cityName,
      'full_address': fullAddress,
    });
    if (isMain) {
      await _api.post('/addresses/$id/set-main', {});
    }
  }

  Future<void> deleteAddress(String id) => _api.delete('/addresses/$id');

  Future<void> setMain(String id) => _api.post('/addresses/$id/set-main', {});
}
