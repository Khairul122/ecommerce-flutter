import 'package:flutter/material.dart';
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

import 'features/order/data/datasources/order_remote_data_source.dart';
import 'features/order/data/repositories/order_repository_impl.dart';
import 'features/order/domain/usecases/order_usecases.dart';
import 'features/order/presentation/providers/order_provider.dart';

import 'features/chat/data/datasources/chat_remote_data_source.dart';
import 'features/chat/data/repositories/chat_repository_impl.dart';
import 'features/chat/domain/usecases/chat_usecases.dart';
import 'features/chat/presentation/providers/chat_provider.dart';

import 'features/store/data/datasources/store_remote_data_source.dart';
import 'features/store/data/repositories/store_repository_impl.dart';
import 'features/store/domain/usecases/store_usecases.dart';
import 'features/store/presentation/providers/store_provider.dart';

import 'features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'features/dashboard/domain/usecases/dashboard_usecases.dart';
import 'features/dashboard/presentation/providers/dashboard_provider.dart';

import 'features/splash/presentation/splash_page.dart';

// Firebase (Auth, Firestore, Messaging, Crashlytics, Storage) dan koneksi
// MySQL langsung dari mobile (mysql_service.dart) sudah dihapus seluruhnya
// sesuai audit keamanan. Backend sekarang Laravel REST API + Sanctum token.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp(deps: AppDependencies.build()));
}

/// Susunan dependency injection manual (tanpa package DI) untuk seluruh
/// aplikasi: core service -> data source -> repository -> use case ->
/// provider. Provider fitur lain ditambahkan di sini juga saat dibuat.
class AppDependencies {
  final AuthProvider authProvider;
  final ProductProvider productProvider;
  final OrderProvider orderProvider;
  final ChatProvider chatProvider;
  final StoreProvider storeProvider;
  final DashboardProvider dashboardProvider;

  AppDependencies._({
    required this.authProvider,
    required this.productProvider,
    required this.orderProvider,
    required this.chatProvider,
    required this.storeProvider,
    required this.dashboardProvider,
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
      restoreSessionUseCase: RestoreSessionUseCase(authRepository),
      registerOwnerUseCase: RegisterOwnerUseCase(authRepository),
      loginUseCase: LoginUseCase(authRepository),
      getMeUseCase: GetMeUseCase(authRepository),
      updatePasswordUseCase: UpdatePasswordUseCase(authRepository),
      updateProfileUseCase: UpdateProfileUseCase(authRepository),
      forgotPasswordUseCase: ForgotPasswordUseCase(authRepository),
      deleteAccountUseCase: DeleteAccountUseCase(authRepository),
      signOutUseCase: SignOutUseCase(authRepository),
    );

    final productRemote = ProductRemoteDataSource(apiService);
    final productRepository = ProductRepositoryImpl(remote: productRemote);
    final productProvider = ProductProvider(
      getMyProductsUseCase: GetMyProductsUseCase(productRepository),
      addProductUseCase: AddProductUseCase(productRepository),
      updateProductUseCase: UpdateProductUseCase(productRepository),
      deleteProductUseCase: DeleteProductUseCase(productRepository),
      getCategoriesUseCase: GetCategoriesUseCase(productRepository),
      addCategoryUseCase: AddCategoryUseCase(productRepository),
      updateCategoryUseCase: UpdateCategoryUseCase(productRepository),
      deleteCategoryUseCase: DeleteCategoryUseCase(productRepository),
      uploadProductImageUseCase: UploadProductImageUseCase(productRepository),
    );

    final orderRemote = OrderRemoteDataSource(apiService);
    final orderRepository = OrderRepositoryImpl(remote: orderRemote);
    final orderProvider = OrderProvider(
      getOrdersUseCase: GetOrdersUseCase(orderRepository),
      getOrderUseCase: GetOrderUseCase(orderRepository),
      updateOrderStatusUseCase: UpdateOrderStatusUseCase(orderRepository),
      confirmPaymentUseCase: ConfirmPaymentUseCase(orderRepository),
      getOrderStatsUseCase: GetOrderStatsUseCase(orderRepository),
    );

    final chatRemote = ChatRemoteDataSource(apiService);
    final chatRepository = ChatRepositoryImpl(remote: chatRemote);
    final chatProvider = ChatProvider(
      getConversationsUseCase: GetConversationsUseCase(chatRepository),
      getMessagesUseCase: GetMessagesUseCase(chatRepository),
      sendMessageUseCase: SendMessageUseCase(chatRepository),
    );

    final storeRemote = StoreRemoteDataSource(apiService);
    final storeRepository = StoreRepositoryImpl(remote: storeRemote);
    final storeProvider = StoreProvider(
      getStoreUseCase: GetStoreUseCase(storeRepository),
      updateStoreUseCase: UpdateStoreUseCase(storeRepository),
      uploadLogoUseCase: UploadLogoUseCase(storeRepository),
      removeLogoUseCase: RemoveLogoUseCase(storeRepository),
    );

    final dashboardRemote = DashboardRemoteDataSource(apiService);
    final dashboardRepository = DashboardRepositoryImpl(remote: dashboardRemote);
    final dashboardProvider = DashboardProvider(
      getStatsUseCase: GetStatsUseCase(dashboardRepository),
    );

    return AppDependencies._(
      authProvider: authProvider,
      productProvider: productProvider,
      orderProvider: orderProvider,
      chatProvider: chatProvider,
      storeProvider: storeProvider,
      dashboardProvider: dashboardProvider,
    );
  }
}

class MyApp extends StatelessWidget {
  final AppDependencies deps;
  const MyApp({super.key, required this.deps});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: deps.authProvider),
        ChangeNotifierProvider.value(value: deps.productProvider),
        ChangeNotifierProvider.value(value: deps.orderProvider),
        ChangeNotifierProvider.value(value: deps.chatProvider),
        ChangeNotifierProvider.value(value: deps.storeProvider),
        ChangeNotifierProvider.value(value: deps.dashboardProvider),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Ootday Owner',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const SplashPage(),
      ),
    );
  }
}
