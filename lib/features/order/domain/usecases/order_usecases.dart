import '../../../../core/usecase.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class GetOrdersParams {
  final String? status;
  const GetOrdersParams({this.status});
}

class GetOrdersUseCase extends UseCase<List<OrderEntity>, GetOrdersParams> {
  final OrderRepository repository;
  GetOrdersUseCase(this.repository);

  @override
  Future<List<OrderEntity>> call(GetOrdersParams params) =>
      repository.getOrders(status: params.status);
}

class GetOrderUseCase extends UseCase<OrderEntity, int> {
  final OrderRepository repository;
  GetOrderUseCase(this.repository);

  @override
  Future<OrderEntity> call(int id) => repository.getOrder(id);
}

class UpdateOrderStatusParams {
  final int id;
  final String status;
  final String? cancelReason;
  const UpdateOrderStatusParams({
    required this.id,
    required this.status,
    this.cancelReason,
  });
}

class UpdateOrderStatusUseCase extends UseCase<void, UpdateOrderStatusParams> {
  final OrderRepository repository;
  UpdateOrderStatusUseCase(this.repository);

  @override
  Future<void> call(UpdateOrderStatusParams params) => repository.updateStatus(
        params.id,
        status: params.status,
        cancelReason: params.cancelReason,
      );
}

class ConfirmPaymentUseCase extends UseCase<void, int> {
  final OrderRepository repository;
  ConfirmPaymentUseCase(this.repository);

  @override
  Future<void> call(int id) => repository.confirmPayment(id);
}

class GetOrderStatsUseCase extends UseCase<Map<String, dynamic>, NoParams> {
  final OrderRepository repository;
  GetOrderStatsUseCase(this.repository);

  @override
  Future<Map<String, dynamic>> call(NoParams params) => repository.getStats();
}
