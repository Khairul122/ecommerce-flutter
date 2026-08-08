import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../../core/usecase.dart';
import '../../domain/entities/store_entity.dart';
import '../../domain/usecases/store_usecases.dart';

/// State data toko owner untuk layar profil/informasi toko, dibaca lewat
/// `context.watch<StoreProvider>()` / `context.read<StoreProvider>()`.
class StoreProvider extends ChangeNotifier {
  final GetStoreUseCase getStoreUseCase;
  final UpdateStoreUseCase updateStoreUseCase;
  final SearchStoreDestinationsUseCase searchDestinationsUseCase;
  final UploadLogoUseCase uploadLogoUseCase;
  final RemoveLogoUseCase removeLogoUseCase;

  StoreProvider({
    required this.getStoreUseCase,
    required this.updateStoreUseCase,
    required this.searchDestinationsUseCase,
    required this.uploadLogoUseCase,
    required this.removeLogoUseCase,
  });

  StoreEntity? _store;
  bool _isLoading = false;
  String? _error;

  StoreEntity? get store => _store;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadStore() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _store = await getStoreUseCase(const NoParams());
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<StoreEntity> updateStore({
    String? storeName,
    String? description,
    String? address,
    String? phone,
    String? logoUrl,
    int? districtId,
    String? districtName,
    String? cityName,
    String? provinceName,
    String? postalCode,
  }) async {
    _store = await updateStoreUseCase(UpdateStoreParams(
      storeName: storeName,
      description: description,
      address: address,
      phone: phone,
      logoUrl: logoUrl,
      districtId: districtId,
      districtName: districtName,
      cityName: cityName,
      provinceName: provinceName,
      postalCode: postalCode,
    ));
    notifyListeners();
    return _store!;
  }

  Future<List<Map<String, dynamic>>> searchDestinations(String keyword) {
    return searchDestinationsUseCase(keyword);
  }

  Future<String> uploadLogo(File file) async {
    final url = await uploadLogoUseCase(file);
    if (_store != null) {
      _store = _copyWith(logoUrl: url);
    }
    notifyListeners();
    return url;
  }

  Future<void> removeLogo() async {
    await removeLogoUseCase(const NoParams());
    if (_store != null) {
      _store = _copyWith(clearLogo: true);
    }
    notifyListeners();
  }

  StoreEntity _copyWith({String? logoUrl, bool clearLogo = false}) {
    final s = _store!;
    return StoreEntity(
      storeName: s.storeName,
      description: s.description,
      address: s.address,
      phone: s.phone,
      logoUrl: clearLogo ? null : (logoUrl ?? s.logoUrl),
      districtId: s.districtId,
      districtName: s.districtName,
      cityName: s.cityName,
      provinceName: s.provinceName,
      postalCode: s.postalCode,
    );
  }
}
