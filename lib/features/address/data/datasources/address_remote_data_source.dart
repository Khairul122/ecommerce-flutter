import '../../../../core/services/api_service.dart';
import '../models/address_model.dart';

/// Sumber data remote (REST API Laravel) untuk fitur alamat. Tidak menyimpan
/// state apa pun — murni pemanggilan endpoint dan parsing response.
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

  Future<void> addAddress({
    required String name,
    required String phone,
    required String fullAddress,
    required bool isMain,
  }) {
    return _api.post('/addresses', {
      'receiver_name': name,
      'phone': phone,
      'full_address': fullAddress,
      'is_main': isMain,
    });
  }

  Future<void> updateAddress({
    required String id,
    required String name,
    required String phone,
    required String fullAddress,
    required bool isMain,
  }) async {
    await _api.put('/addresses/$id', {
      'receiver_name': name,
      'phone': phone,
      'full_address': fullAddress,
    });
    if (isMain) {
      await _api.post('/addresses/$id/set-main', {});
    }
  }

  Future<void> deleteAddress(String id) => _api.delete('/addresses/$id');

  Future<void> setMain(String id) => _api.post('/addresses/$id/set-main', {});
}
