import 'dart:io';

import '../../domain/entities/store_entity.dart';
import '../../domain/repositories/store_repository.dart';
import '../datasources/store_remote_data_source.dart';

/// Implementasi [StoreRepository]: mengoordinasikan remote data source
/// (REST API) untuk data toko owner.
class StoreRepositoryImpl implements StoreRepository {
  final StoreRemoteDataSource remote;

  StoreRepositoryImpl({required this.remote});

  @override
  Future<StoreEntity> getStore() => remote.getStore();

  @override
  Future<StoreEntity> updateStore({
    String? storeName,
    String? description,
    String? address,
    String? phone,
    String? logoUrl,
  }) {
    return remote.updateStore({
      if (storeName != null) 'store_name': storeName,
      if (description != null) 'description': description,
      if (address != null) 'address': address,
      if (phone != null) 'phone': phone,
      if (logoUrl != null) 'logo_url': logoUrl,
    });
  }

  @override
  Future<String> uploadLogo(File file) async {
    final url = await remote.uploadFile(file);
    await remote.updateStore({'logo_url': url});
    return url;
  }

  @override
  Future<void> removeLogo() async {
    await remote.updateStore({'logo_url': ''});
  }
}
