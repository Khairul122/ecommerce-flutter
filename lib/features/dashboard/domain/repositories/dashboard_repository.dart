import '../entities/dashboard_stats_entity.dart';

/// Kontrak layer domain untuk statistik dashboard owner.
abstract class DashboardRepository {
  Future<DashboardStatsEntity> getStats();
}
