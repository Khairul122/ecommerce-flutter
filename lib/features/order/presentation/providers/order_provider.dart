import 'package:flutter/foundation.dart';
import '../../../../core/usecase.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/usecases/order_usecases.dart';

/// State pesanan untuk seluruh aplikasi, dibaca lewat
/// `context.watch<OrderProvider>()` / `context.read<OrderProvider>()`.
/// Menggantikan pemanggilan `OrderData` langsung dari widget.
///
/// Daftar pesanan disimpan per status (kunci 'all' dipakai untuk status
/// null/semua) supaya tiap tab di my_orders_screen.dart punya cache &
/// loading/error state sendiri-sendiri, meniru perilaku _StatusOrdersTab
/// yang lama.
class OrderProvider extends ChangeNotifier {
  final GetOrdersUseCase getOrdersUseCase;
  final GetActiveOrdersUseCase getActiveOrdersUseCase;
  final GetOrderUseCase getOrderUseCase;
  final ConfirmPaymentUseCase confirmPaymentUseCase;
  final CancelOrderUseCase cancelOrderUseCase;

  OrderProvider({
    required this.getOrdersUseCase,
    required this.getActiveOrdersUseCase,
    required this.getOrderUseCase,
    required this.confirmPaymentUseCase,
    required this.cancelOrderUseCase,
  });

  static const String _allKey = 'all';

  final Map<String, List<OrderEntity>> _ordersByStatus = {};
  final Map<String, bool> _loadingByStatus = {};
  final Map<String, String?> _errorByStatus = {};

  OrderEntity? _selectedOrder;
  bool _detailLoading = false;
  String? _detailError;
  bool _isMutating = false;

  List<OrderEntity> ordersFor(String? status) =>
      _ordersByStatus[status ?? _allKey] ?? const [];

  bool isLoading(String? status) => _loadingByStatus[status ?? _allKey] ?? false;

  String? errorFor(String? status) => _errorByStatus[status ?? _allKey];

  OrderEntity? get selectedOrder => _selectedOrder;
  bool get detailLoading => _detailLoading;
  String? get detailError => _detailError;
  bool get isMutating => _isMutating;

  Future<void> fetchOrders({String? status}) async {
    final key = status ?? _allKey;
    _loadingByStatus[key] = true;
    _errorByStatus[key] = null;
    notifyListeners();
    try {
      _ordersByStatus[key] = await getOrdersUseCase(status);
    } catch (e) {
      _errorByStatus[key] = e.toString();
    } finally {
      _loadingByStatus[key] = false;
      notifyListeners();
    }
  }

  /// Dipertahankan untuk kompatibilitas pemanggil lama yang menghitung badge
  /// "pesanan aktif" (status diproses).
  Future<List<OrderEntity>> getActiveOrders() => getActiveOrdersUseCase(const NoParams());

  Future<void> fetchOrderDetail(String orderId) async {
    _detailLoading = true;
    _detailError = null;
    notifyListeners();
    try {
      _selectedOrder = await getOrderUseCase(orderId);
    } catch (e) {
      _detailError = e.toString();
    } finally {
      _detailLoading = false;
      notifyListeners();
    }
  }

  void clearSelectedOrder() {
    _selectedOrder = null;
    _detailError = null;
    _detailLoading = false;
  }

  Future<OrderEntity> confirmPayment(String orderId, {String? paymentProofUrl}) async {
    _isMutating = true;
    notifyListeners();
    try {
      final updated = await confirmPaymentUseCase(
        ConfirmPaymentParams(orderId: orderId, paymentProofUrl: paymentProofUrl),
      );
      _selectedOrder = updated;
      return updated;
    } finally {
      _isMutating = false;
      notifyListeners();
    }
  }

  Future<OrderEntity> cancelOrder(String orderId, {String? reason}) async {
    _isMutating = true;
    notifyListeners();
    try {
      final updated = await cancelOrderUseCase(
        CancelOrderParams(orderId: orderId, reason: reason),
      );
      _selectedOrder = updated;
      return updated;
    } finally {
      _isMutating = false;
      notifyListeners();
    }
  }
}
