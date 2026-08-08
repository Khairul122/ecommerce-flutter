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
    int? districtId,
    String? districtName,
    String? cityName,
    String? provinceName,
    String? postalCode,
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
      if (districtId != null) 'district_id': districtId,
      if (districtName != null) 'district_name': districtName,
      if (cityName != null) 'city_name': cityName,
      if (provinceName != null) 'province_name': provinceName,
      if (postalCode != null) 'postal_code': postalCode,
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
    int? districtId,
    String? districtName,
    String? cityName,
    String? provinceName,
    String? postalCode,
  }) async {
    await _api.put('/addresses/$id', {
      'receiver_name': name,
      'phone': phone,
      'province_id': provinceId,
      'province_name': provinceName,
      'city_id': cityId,
      'city_name': cityName,
      'full_address': fullAddress,
      if (districtId != null) 'district_id': districtId,
      if (districtName != null) 'district_name': districtName,
      if (cityName != null) 'city_name': cityName,
      if (provinceName != null) 'province_name': provinceName,
      if (postalCode != null) 'postal_code': postalCode,
    });
    if (isMain) {
      await _api.post('/addresses/$id/set-main', {});
    }
  }

  Future<void> deleteAddress(String id) => _api.delete('/addresses/$id');

  Future<void> setMain(String id) => _api.post('/addresses/$id/set-main', {});

  /// Autocomplete kecamatan/kota (RajaOngkir) dipakai form alamat.
  Future<List<Map<String, dynamic>>> searchDestinations(String keyword) async {
    final result = await _api.get('/shipping/destinations?search=${Uri.encodeQueryComponent(keyword)}');
    final List raw = result['data'] ?? [];
    return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
}
