import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'core/services/api_service.dart';
import 'core/services/token_storage.dart';

import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/auth_usecases.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

import 'features/product/data/datasources/product_remote_data_source.dart';
import 'features/product/data/repositories/product_repository_impl.dart';
import 'features/product/domain/usecases/product_usecases.dart';
import 'features/product/presentation/providers/product_provider.dart';

import 'features/cart/data/datasources/cart_remote_data_source.dart';
import 'features/cart/data/repositories/cart_repository_impl.dart';
import 'features/cart/domain/usecases/cart_usecases.dart';
import 'features/cart/presentation/providers/cart_provider.dart';

import 'features/address/data/datasources/address_remote_data_source.dart';
import 'features/address/data/repositories/address_repository_impl.dart';
import 'features/address/domain/usecases/address_usecases.dart';
import 'features/address/presentation/providers/address_provider.dart';

import 'features/order/data/datasources/order_remote_data_source.dart';
import 'features/order/data/repositories/order_repository_impl.dart';
import 'features/order/domain/usecases/order_usecases.dart';
import 'features/order/presentation/providers/order_provider.dart';

import 'features/chat/data/datasources/chat_remote_data_source.dart';
import 'features/chat/data/repositories/chat_repository_impl.dart';
import 'features/chat/domain/usecases/chat_usecases.dart';
import 'features/chat/presentation/providers/chat_provider.dart';

import 'features/checkout/data/datasources/checkout_remote_data_source.dart';
import 'features/checkout/data/repositories/checkout_repository_impl.dart';
import 'features/checkout/domain/usecases/checkout_usecases.dart';
import 'features/checkout/presentation/providers/checkout_provider.dart';

import 'features/onboarding/presentation/welcome_screen.dart';
import 'features/home/presentation/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));

  runApp(OotdayApp(deps: AppDependencies.build()));
}

/// Susunan dependency injection manual (tanpa package DI) untuk seluruh
/// aplikasi: core service -> data source -> repository -> use case ->
/// provider. Provider baru untuk fitur lain ditambahkan di sini juga.
class AppDependencies {
  final AuthProvider authProvider;
  final ProductProvider productProvider;
  final CartProvider cartProvider;
  final AddressProvider addressProvider;
  final OrderProvider orderProvider;
  final ChatProvider chatProvider;
  final CheckoutProvider checkoutProvider;

  AppDependencies._({
    required this.authProvider,
    required this.productProvider,
    required this.cartProvider,
    required this.addressProvider,
    required this.orderProvider,
    required this.chatProvider,
    required this.checkoutProvider,
  });

  factory AppDependencies.build() {
    const secureStorage = FlutterSecureStorage();
    const tokenStorage = TokenStorage(secureStorage);
    final apiService = ApiService(tokenStorage: tokenStorage);

    final authRemote = AuthRemoteDataSource(apiService);
    final authLocal = AuthLocalDataSource(secureStorage);
    final authRepository = AuthRepositoryImpl(
      remote: authRemote,
      local: authLocal,
      tokenStorage: tokenStorage,
    );
    final authProvider = AuthProvider(
      loadSessionUseCase: LoadSessionUseCase(authRepository),
      loginUseCase: LoginUseCase(authRepository),
      registerUseCase: RegisterUseCase(authRepository),
      refreshMeUseCase: RefreshMeUseCase(authRepository),
      changePasswordUseCase: ChangePasswordUseCase(authRepository),
      forgotPasswordUseCase: ForgotPasswordUseCase(authRepository),
      resetPasswordUseCase: ResetPasswordUseCase(authRepository),
      deleteAccountUseCase: DeleteAccountUseCase(authRepository),
      signOutUseCase: SignOutUseCase(authRepository),
    );

    final productRemote = ProductRemoteDataSource(apiService);
    final productRepository = ProductRepositoryImpl(remote: productRemote);
    final productProvider = ProductProvider(
      getProductsUseCase: GetProductsUseCase(productRepository),
      getProductUseCase: GetProductUseCase(productRepository),
      getCategoriesUseCase: GetCategoriesUseCase(productRepository),
    );

    final cartRemote = CartRemoteDataSource(apiService);
    final cartRepository = CartRepositoryImpl(remote: cartRemote);
    final cartProvider = CartProvider(
      getCartItemsUseCase: GetCartItemsUseCase(cartRepository),
      addToCartUseCase: AddToCartUseCase(cartRepository),
      buyNowUseCase: BuyNowUseCase(cartRepository),
      updateQuantityUseCase: UpdateQuantityUseCase(cartRepository),
      updateSelectionUseCase: UpdateSelectionUseCase(cartRepository),
      updateSelectAllUseCase: UpdateSelectAllUseCase(cartRepository),
      deleteCartItemUseCase: DeleteCartItemUseCase(cartRepository),
    );

    final addressRemote = AddressRemoteDataSource(apiService);
    final addressRepository = AddressRepositoryImpl(remote: addressRemote);
    final addressProvider = AddressProvider(
      getAddressesUseCase: GetAddressesUseCase(addressRepository),
      addAddressUseCase: AddAddressUseCase(addressRepository),
      updateAddressUseCase: UpdateAddressUseCase(addressRepository),
      deleteAddressUseCase: DeleteAddressUseCase(addressRepository),
      setMainAddressUseCase: SetMainAddressUseCase(addressRepository),
    );

    final orderRemote = OrderRemoteDataSource(apiService);
    final orderRepository = OrderRepositoryImpl(remote: orderRemote);
    final orderProvider = OrderProvider(
      getOrdersUseCase: GetOrdersUseCase(orderRepository),
      getActiveOrdersUseCase: GetActiveOrdersUseCase(orderRepository),
      getOrderUseCase: GetOrderUseCase(orderRepository),
      confirmPaymentUseCase: ConfirmPaymentUseCase(orderRepository),
      cancelOrderUseCase: CancelOrderUseCase(orderRepository),
    );

    final chatRemote = ChatRemoteDataSource(apiService);
    final chatRepository = ChatRepositoryImpl(remote: chatRemote);
    final chatProvider = ChatProvider(
      getConversationsUseCase: GetConversationsUseCase(chatRepository),
      startConversationUseCase: StartConversationUseCase(chatRepository),
      getMessagesUseCase: GetMessagesUseCase(chatRepository),
      sendMessageUseCase: SendMessageUseCase(chatRepository),
    );

    final checkoutRemote = CheckoutRemoteDataSource(apiService);
    final checkoutRepository = CheckoutRepositoryImpl(remote: checkoutRemote);
    final checkoutProvider = CheckoutProvider(
      getPaymentMethodsUseCase: GetPaymentMethodsUseCase(checkoutRepository),
      getShippingMethodsUseCase: GetShippingMethodsUseCase(checkoutRepository),
      createOrderUseCase: CreateOrderUseCase(checkoutRepository),
    );

    return AppDependencies._(
      authProvider: authProvider,
      productProvider: productProvider,
      cartProvider: cartProvider,
      addressProvider: addressProvider,
      orderProvider: orderProvider,
      chatProvider: chatProvider,
      checkoutProvider: checkoutProvider,
    );
  }
}

class OotdayApp extends StatelessWidget {
  final AppDependencies deps;
  const OotdayApp({super.key, required this.deps});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: deps.authProvider),
        ChangeNotifierProvider.value(value: deps.productProvider),
        ChangeNotifierProvider.value(value: deps.cartProvider),
        ChangeNotifierProvider.value(value: deps.addressProvider),
        ChangeNotifierProvider.value(value: deps.orderProvider),
        ChangeNotifierProvider.value(value: deps.chatProvider),
        ChangeNotifierProvider.value(value: deps.checkoutProvider),
      ],
      child: MaterialApp(
        title: 'Ootday Pelanggan',
        debugShowCheckedModeBanner: false,
        home: const _SessionGate(),
      ),
    );
  }
}

/// Menggantikan `FirebaseAuth.instance.authStateChanges()`: sesi login
/// sekarang disimpan lewat flutter_secure_storage (token Sanctum), dimuat
/// sekali di awal lewat [AuthProvider.loadSession] untuk memutuskan halaman
/// pertama.
class _SessionGate extends StatelessWidget {
  const _SessionGate();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: context.read<AuthProvider>().loadSession(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final isLoggedIn = context.watch<AuthProvider>().isLoggedIn;
        return isLoggedIn ? const HomeScreen() : const WelcomeScreen();
      },
    );
  }
}
