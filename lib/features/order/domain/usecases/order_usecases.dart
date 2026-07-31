import '../../../../core/usecase.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class GetOrdersUseCase extends UseCase<List<OrderEntity>, String?> {
  final OrderRepository repository;
  GetOrdersUseCase(this.repository);

  @override
  Future<List<OrderEntity>> call(String? status) =>
      repository.getOrders(status: status);
}

class GetActiveOrdersUseCase extends UseCase<List<OrderEntity>, NoParams> {
  final OrderRepository repository;
  GetActiveOrdersUseCase(this.repository);

  @override
  Future<List<OrderEntity>> call(NoParams params) =>
      repository.getActiveOrders();
}

class GetOrderUseCase extends UseCase<OrderEntity, String> {
  final OrderRepository repository;
  GetOrderUseCase(this.repository);

  @override
  Future<OrderEntity> call(String orderId) => repository.getOrder(orderId);
}

class ConfirmPaymentParams {
  final String orderId;
  final String? paymentProofUrl;
  const ConfirmPaymentParams({required this.orderId, this.paymentProofUrl});
}

class ConfirmPaymentUseCase extends UseCase<OrderEntity, ConfirmPaymentParams> {
  final OrderRepository repository;
  ConfirmPaymentUseCase(this.repository);

  @override
  Future<OrderEntity> call(ConfirmPaymentParams params) => repository.confirmPayment(
        params.orderId,
        paymentProofUrl: params.paymentProofUrl,
      );
}

class CancelOrderParams {
  final String orderId;
  final String? reason;
  const CancelOrderParams({required this.orderId, this.reason});
}

class CancelOrderUseCase extends UseCase<OrderEntity, CancelOrderParams> {
  final OrderRepository repository;
  CancelOrderUseCase(this.repository);

  @override
  Future<OrderEntity> call(CancelOrderParams params) =>
      repository.cancelOrder(params.orderId, reason: params.reason);
}
