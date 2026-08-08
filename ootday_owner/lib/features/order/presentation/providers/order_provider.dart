import 'package:flutter/foundation.dart';
import '../../../../core/usecase.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/usecases/order_usecases.dart';

/// State manajemen pesanan owner untuk seluruh aplikasi, dibaca lewat
/// `context.watch<OrderProvider>()` / `context.read<OrderProvider>()`.
/// Menggantikan pemanggilan `ApiService()` langsung dari widget order.
class OrderProvider extends ChangeNotifier {
  final GetOrdersUseCase getOrdersUseCase;
  final GetOrderUseCase getOrderUseCase;
  final UpdateOrderStatusUseCase updateOrderStatusUseCase;
  final ConfirmPaymentUseCase confirmPaymentUseCase;
  final GetOrderStatsUseCase getOrderStatsUseCase;

  OrderProvider({
    required this.getOrdersUseCase,
    required this.getOrderUseCase,
    required this.updateOrderStatusUseCase,
    required this.confirmPaymentUseCase,
    required this.getOrderStatsUseCase,
  });

  List<OrderEntity> _orders = [];
  bool _isLoadingOrders = false;
  String? _ordersError;

  Map<String, dynamic>? _stats;
  bool _isLoadingStats = false;

  List<OrderEntity> get orders => _orders;
  bool get isLoadingOrders => _isLoadingOrders;
  String? get ordersError => _ordersError;

  Map<String, dynamic>? get stats => _stats;
  bool get isLoadingStats => _isLoadingStats;

  Future<void> fetchOrders({String? status}) async {
    _isLoadingOrders = true;
    _ordersError = null;
    notifyListeners();
    try {
      _orders = await getOrdersUseCase(GetOrdersParams(status: status));
    } catch (e) {
      _ordersError = '$e';
    } finally {
      _isLoadingOrders = false;
      notifyListeners();
    }
  }

  Future<OrderEntity> getOrder(int id) => getOrderUseCase(id);

  Future<void> updateStatus(
    int id, {
    required String status,
    String? cancelReason,
    String? trackingNumber,
  }) {
    return updateOrderStatusUseCase(UpdateOrderStatusParams(
      id: id,
      status: status,
      cancelReason: cancelReason,
      trackingNumber: trackingNumber,
    ));
  }

  Future<void> confirmPayment(int id) => confirmPaymentUseCase(id);

  Future<void> fetchStats() async {
    _isLoadingStats = true;
    notifyListeners();
    try {
      _stats = await getOrderStatsUseCase(const NoParams());
    } catch (_) {
      // Perbaikan perilaku: halaman lama diam-diam mengabaikan error stats
      // (hanya mematikan loading), jadi perilakunya dipertahankan di sini.
    } finally {
      _isLoadingStats = false;
      notifyListeners();
    }
  }
}
