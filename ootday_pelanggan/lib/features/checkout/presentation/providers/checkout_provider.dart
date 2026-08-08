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
  final GetShippingCostUseCase getShippingCostUseCase;
  final CreateOrderUseCase createOrderUseCase;

  CheckoutProvider({
    required this.getPaymentMethodsUseCase,
    required this.getShippingCostUseCase,
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

  /// Dipakai checkout_screen.dart: memuat metode pembayaran. Ongkir tidak
  /// dimuat di sini karena butuh alamat tujuan -- lihat [loadShippingCost].
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

  /// Dipakai checkout_screen.dart & shipping_method_screen.dart: ongkir live
  /// RajaOngkir dari toko ke district alamat [addressId].
  Future<void> loadShippingCost(String addressId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _shippingMethods = await getShippingCostUseCase(addressId);
    } catch (e) {
      _error = 'Gagal memuat opsi pengiriman: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<OrderEntity> createOrder({
    required String addressId,
    required int shippingMethodId,
    required int paymentMethodId,
    num? shippingCost,
    String? shippingService,
  }) async {
    _isPlacingOrder = true;
    notifyListeners();
    try {
      return await createOrderUseCase(CreateOrderParams(
        addressId: addressId,
        shippingMethodId: shippingMethodId,
        paymentMethodId: paymentMethodId,
        shippingCost: shippingCost,
        shippingService: shippingService,
      ));
    } finally {
      _isPlacingOrder = false;
      notifyListeners();
    }
  }
}
