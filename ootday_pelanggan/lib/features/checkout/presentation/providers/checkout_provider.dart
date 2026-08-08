import 'package:flutter/foundation.dart';
import '../../../../core/usecase.dart';
import '../../../order/domain/entities/order_entity.dart';
import '../../domain/entities/payment_method_entity.dart';
import '../../domain/entities/rajaongkir_cost_entity.dart';
import '../../domain/entities/shipping_method_entity.dart';
import '../../domain/usecases/checkout_usecases.dart';

class CheckoutProvider extends ChangeNotifier {
  final GetPaymentMethodsUseCase getPaymentMethodsUseCase;
  final GetShippingMethodsUseCase getShippingMethodsUseCase;
  final CheckShippingCostUseCase checkShippingCostUseCase;
  final CreateOrderUseCase createOrderUseCase;

  CheckoutProvider({
    required this.getPaymentMethodsUseCase,
    required this.getShippingMethodsUseCase,
    required this.checkShippingCostUseCase,
    required this.createOrderUseCase,
  });

  List<PaymentMethodEntity> _paymentMethods = [];
  List<ShippingMethodEntity> _shippingMethods = [];
  List<RajaOngkirCourierEntity> _rajaOngkirOptions = [];

  String? _selectedCourier;
  ShippingServiceCostEntity? _selectedServiceCost;

  bool _isLoading = false;
  bool _isLoadingRajaOngkir = false;
  String? _error;
  bool _isPlacingOrder = false;

  List<PaymentMethodEntity> get paymentMethods => _paymentMethods;
  List<ShippingMethodEntity> get shippingMethods => _shippingMethods;
  List<RajaOngkirCourierEntity> get rajaOngkirOptions => _rajaOngkirOptions;

  String? get selectedCourier => _selectedCourier;
  ShippingServiceCostEntity? get selectedServiceCost => _selectedServiceCost;

  bool get isLoading => _isLoading;
  bool get isLoadingRajaOngkir => _isLoadingRajaOngkir;
  String? get error => _error;
  bool get isPlacingOrder => _isPlacingOrder;

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

  Future<void> loadRajaOngkirOptions({
    required int destinationCityId,
    required int totalWeightGram,
  }) async {
    _isLoadingRajaOngkir = true;
    _error = null;
    notifyListeners();

    try {
      final couriers = ['jne', 'pos', 'tiki'];
      final List<RajaOngkirCourierEntity> allOptions = [];

      for (final courier in couriers) {
        final res = await checkShippingCostUseCase(CheckShippingCostParams(
          destinationCityId: destinationCityId,
          totalWeightGram: totalWeightGram,
          courier: courier,
        ));
        allOptions.addAll(res);
      }

      _rajaOngkirOptions = allOptions;

      if (_selectedServiceCost == null && _rajaOngkirOptions.isNotEmpty) {
        for (final c in _rajaOngkirOptions) {
          if (c.services.isNotEmpty) {
            _selectedCourier = c.code.toUpperCase();
            _selectedServiceCost = c.services.first;
            break;
          }
        }
      }
    } catch (e) {
      _error = 'Gagal memuat ongkir RajaOngkir: $e';
    } finally {
      _isLoadingRajaOngkir = false;
      notifyListeners();
    }
  }

  void selectRajaOngkirOption(String courierCode, ShippingServiceCostEntity serviceCost) {
    _selectedCourier = courierCode.toUpperCase();
    _selectedServiceCost = serviceCost;
    notifyListeners();
  }

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
      _shippingMethods = await getShippingMethodsUseCase(const NoParams());
    } catch (e) {
      _error = 'Gagal memuat opsi pengiriman: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<OrderEntity> createOrder({
    required String addressId,
    int? shippingMethodId,
    required int paymentMethodId,
    String? shippingCourier,
    String? shippingService,
    int? shippingCost,
    String? shippingEtd,
  }) async {
    _isPlacingOrder = true;
    notifyListeners();
    try {
      return await createOrderUseCase(CreateOrderParams(
        addressId: addressId,
        shippingMethodId: shippingMethodId,
        paymentMethodId: paymentMethodId,
        shippingCourier: shippingCourier ?? _selectedCourier,
        shippingService: shippingService ?? _selectedServiceCost?.service,
        shippingCost: shippingCost ?? _selectedServiceCost?.cost,
        shippingEtd: shippingEtd ?? _selectedServiceCost?.etd,
      ));
    } finally {
      _isPlacingOrder = false;
      notifyListeners();
    }
  }
}
