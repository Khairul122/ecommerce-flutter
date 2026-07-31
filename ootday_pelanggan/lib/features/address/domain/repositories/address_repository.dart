import '../entities/address_entity.dart';

/// Kontrak layer domain untuk fitur alamat. Implementasinya (data layer)
/// menentukan dari mana data ini datang (REST API Laravel `/addresses`).
abstract class AddressRepository {
  Future<List<AddressEntity>> getAddresses();

  Future<void> addAddress({
    required String name,
    required String phone,
    required String fullAddress,
    required bool isMain,
  });

  Future<void> updateAddress({
    required String id,
    required String name,
    required String phone,
    required String fullAddress,
    required bool isMain,
  });

  Future<void> deleteAddress(String id);

  Future<void> setMain(String id);
}
