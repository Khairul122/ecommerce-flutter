import '../../../../core/usecase.dart';
import '../entities/dashboard_stats_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetStatsUseCase extends UseCase<DashboardStatsEntity, NoParams> {
  final DashboardRepository repository;
  GetStatsUseCase(this.repository);

  @override
  Future<DashboardStatsEntity> call(NoParams params) => repository.getStats();
}
