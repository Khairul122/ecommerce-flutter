import 'package:flutter/foundation.dart';
import '../../../../core/usecase.dart';
import '../../../order/domain/entities/order_entity.dart';
import '../../domain/entities/payment_method_entity.dart';
import '../../domain/entities/shipping_method_entity.dart';
import '../../domain/usecases/checkout_usecases.dart';

/// State fitur checkout untuk seluruh aplikasi, dibaca lewat
/// `context.watch<CheckoutProvider>()` / `context.read<CheckoutProvider>()`.
/// Menggantikan pemanggilan `ApiService`/`OrderData` langsung dari
/// checkout_screen.dart, shipping_method_screen.dart, dan
/// payment_method_screen.dart.
class CheckoutProvider extends ChangeNotifier {
  final GetPaymentMethodsUseCase getPaymentMethodsUseCase;
  final GetShippingMethodsUseCase getShippingMethodsUseCase;
  final CreateOrderUseCase createOrderUseCase;

  CheckoutProvider({
    required this.getPaymentMethodsUseCase,
    required this.getShippingMethodsUseCase,
    required this.createOrderUseCase,
  });

  List<PaymentMethodEntity> _paymentMethods = [];
  List<ShippingMethodEntity> _shippingMethods = [];
  bool _isLoading = false;
  String? _error;
  bool _isPlacingOrder = false;

  List<PaymentMethodEntity> get paymentMethods => _paymentMethods;
  List<ShippingMethodEntity> get shippingMethods => _shippingMethods;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isPlacingOrder => _isPlacingOrder;

  /// Dipakai checkout_screen.dart: memuat opsi pengiriman & metode
  /// pembayaran sekaligus.
  Future<void> loadCheckoutMethods() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        getShippingMethodsUseCase(const NoParams()),
        getPaymentMethodsUseCase(const NoParams()),
      ]);
      _shippingMethods = results[0] as List<ShippingMethodEntity>;
      _paymentMethods = results[1] as List<PaymentMethodEntity>;
    } catch (e) {
      _error = 'Gagal memuat data checkout: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Dipakai shipping_method_screen.dart.
  Future<void> loadShippingMethods() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _shippingMethods = await getShippingMethodsUseCase(const NoParams());
    } catch (e) {
      _error = 'Gagal memuat opsi pengiriman: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Dipakai payment_method_screen.dart.
  Future<void> loadPaymentMethods() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _paymentMethods = await getPaymentMethodsUseCase(const NoParams());
    } catch (e) {
      _error = 'Gagal memuat metode pembayaran: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<OrderEntity> createOrder({
    required String addressId,
    required int shippingMethodId,
    required int paymentMethodId,
  }) async {
    _isPlacingOrder = true;
    notifyListeners();
    try {
      return await createOrderUseCase(CreateOrderParams(
        addressId: addressId,
        shippingMethodId: shippingMethodId,
        paymentMethodId: paymentMethodId,
      ));
    } finally {
      _isPlacingOrder = false;
      notifyListeners();
    }
  }
}
