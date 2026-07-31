import '../../domain/entities/address_entity.dart';
import '../../domain/repositories/address_repository.dart';
import '../datasources/address_remote_data_source.dart';

/// Implementasi [AddressRepository]: murni meneruskan ke remote data source
/// (tidak ada cache lokal untuk alamat).
class AddressRepositoryImpl implements AddressRepository {
  final AddressRemoteDataSource remote;

  AddressRepositoryImpl({required this.remote});

  @override
  Future<List<AddressEntity>> getAddresses() => remote.getAddresses();

  @override
  Future<void> addAddress({
    required String name,
    required String phone,
    required String fullAddress,
    required bool isMain,
  }) {
    return remote.addAddress(
      name: name,
      phone: phone,
      fullAddress: fullAddress,
      isMain: isMain,
    );
  }

  @override
  Future<void> updateAddress({
    required String id,
    required String name,
    required String phone,
    required String fullAddress,
    required bool isMain,
  }) {
    return remote.updateAddress(
      id: id,
      name: name,
      phone: phone,
      fullAddress: fullAddress,
      isMain: isMain,
    );
  }

  @override
  Future<void> deleteAddress(String id) => remote.deleteAddress(id);

  @override
  Future<void> setMain(String id) => remote.setMain(id);
}
