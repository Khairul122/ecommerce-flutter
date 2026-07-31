import '../../../../core/services/api_service.dart';
import '../models/dashboard_stats_model.dart';

/// Sumber data remote (REST API Laravel) untuk statistik dashboard owner.
class DashboardRemoteDataSource {
  final ApiService _api;
  DashboardRemoteDataSource(this._api);

  Future<DashboardStatsModel> getStats() async {
    final res = await _api.get('/owner/stats');
    final data = res['data'] as Map<String, dynamic>? ?? {};
    return DashboardStatsModel.fromJson(data);
  }
}
