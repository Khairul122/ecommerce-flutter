import 'package:flutter/foundation.dart';
import '../../../../core/usecase.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/usecases/address_usecases.dart';

class AddressProvider extends ChangeNotifier {
  final GetAddressesUseCase getAddressesUseCase;
  final AddAddressUseCase addAddressUseCase;
  final UpdateAddressUseCase updateAddressUseCase;
  final DeleteAddressUseCase deleteAddressUseCase;
  final SetMainAddressUseCase setMainAddressUseCase;
  final SearchDestinationsUseCase searchDestinationsUseCase;

  AddressProvider({
    required this.getAddressesUseCase,
    required this.addAddressUseCase,
    required this.updateAddressUseCase,
    required this.deleteAddressUseCase,
    required this.setMainAddressUseCase,
    required this.searchDestinationsUseCase,
  });

  List<AddressEntity> _addresses = [];
  bool _isLoading = false;
  String? _error;

  List<AddressEntity> get addresses => _addresses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAddresses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _addresses = await getAddressesUseCase(const NoParams());
    } catch (e) {
      _error = 'Gagal memuat alamat: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
    String? postalCode,
  }) async {
    await addAddressUseCase(AddAddressParams(
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
      postalCode: postalCode,
    ));
    await loadAddresses();
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
    String? postalCode,
  }) async {
    await updateAddressUseCase(UpdateAddressParams(
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
      postalCode: postalCode,
    ));
    await loadAddresses();
  }

  Future<void> deleteAddress(String id) async {
    await deleteAddressUseCase(id);
    await loadAddresses();
  }

  Future<void> setMain(String id) async {
    await setMainAddressUseCase(id);
    await loadAddresses();
  }

  Future<List<Map<String, dynamic>>> searchDestinations(String keyword) {
    return searchDestinationsUseCase(keyword);
  }
}
