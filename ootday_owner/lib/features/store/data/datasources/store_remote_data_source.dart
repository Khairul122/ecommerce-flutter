import 'dart:io';

import '../../../../core/services/api_service.dart';
import '../models/store_model.dart';

/// Sumber data remote (REST API Laravel) untuk fitur toko owner.
class StoreRemoteDataSource {
  final ApiService _api;
  StoreRemoteDataSource(this._api);

  Future<StoreModel> getStore() async {
    final res = await _api.get('/owner/store');
    return StoreModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<StoreModel> updateStore(Map<String, dynamic> fields) async {
    final res = await _api.put('/owner/store', fields);
    return StoreModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<String> uploadFile(File file) async {
    final res = await _api.uploadFile('/upload', file);
    return (res['data'] as Map<String, dynamic>)['url'] as String;
  }

  /// Autocomplete kecamatan/kota (RajaOngkir) dipakai form profil toko.
  Future<List<Map<String, dynamic>>> searchDestinations(String keyword) async {
    final result = await _api.get('/shipping/destinations?search=${Uri.encodeQueryComponent(keyword)}');
    final List raw = result['data'] ?? [];
    return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
}
