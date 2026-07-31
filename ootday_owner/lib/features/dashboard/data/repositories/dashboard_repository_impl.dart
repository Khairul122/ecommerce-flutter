import '../../domain/entities/dashboard_stats_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_data_source.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remote;
  DashboardRepositoryImpl({required this.remote});

  @override
  Future<DashboardStatsEntity> getStats() => remote.getStats();
}
