import 'package:flutter/foundation.dart';
import '../../../../core/usecase.dart';
import '../../domain/entities/dashboard_stats_entity.dart';
import '../../domain/usecases/dashboard_usecases.dart';

/// State statistik dashboard owner, dibaca lewat
/// `context.watch<DashboardProvider>()` di `home_page.dart`.
class DashboardProvider extends ChangeNotifier {
  final GetStatsUseCase getStatsUseCase;

  DashboardProvider({required this.getStatsUseCase});

  DashboardStatsEntity? _stats;
  bool _isLoading = false;
  String? _error;

  DashboardStatsEntity? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _stats = await getStatsUseCase(const NoParams());
    } catch (e) {
      _error = '$e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
