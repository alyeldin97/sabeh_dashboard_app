import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/data/remote/auth_data_source.dart';
import '../../features/auth/data/remote/impl/supabase_auth_data_source.dart';
import '../../features/auth/data/repo/auth_repository.dart';
import '../../features/auth/data/repo/auth_repository_impl.dart';
import '../../features/auth/presentation/cubits/auth_cubit.dart';
import '../../features/categories/data/remote/categories_data_source.dart';
import '../../features/customers/data/remote/customers_data_source.dart';
import '../../features/customers/data/remote/impl/supabase_customers_data_source.dart';
import '../../features/customers/data/repo/customers_repository.dart';
import '../../features/customers/data/repo/customers_repository_impl.dart';
import '../../features/customers/presentation/cubits/customers_cubit.dart';
import '../../features/categories/data/remote/impl/supabase_categories_data_source.dart';
import '../../features/categories/data/repo/categories_repository.dart';
import '../../features/categories/data/repo/categories_repository_impl.dart';
import '../../features/categories/presentation/cubits/categories_cubit.dart';
import '../../features/orders/data/remote/impl/supabase_orders_data_source.dart';
import '../../features/orders/data/remote/orders_data_source.dart';
import '../../features/orders/data/repo/orders_repository.dart';
import '../../features/orders/data/repo/orders_repository_impl.dart';
import '../../features/orders/presentation/cubits/orders_cubit.dart';
import '../../features/products/data/remote/impl/supabase_products_data_source.dart';
import '../../features/products/data/remote/products_data_source.dart';
import '../../features/products/data/repo/products_repository.dart';
import '../../features/products/data/repo/products_repository_impl.dart';
import '../../features/products/presentation/cubits/products_cubit.dart';
import '../../features/analytics/presentation/cubits/analytics_cubit.dart';
import '../../features/branches/data/remote/branches_data_source.dart';
import '../../features/branches/data/remote/impl/supabase_branches_data_source.dart';
import '../../features/branches/data/repo/branches_repository.dart';
import '../../features/branches/data/repo/branches_repository_impl.dart';
import '../../features/branches/presentation/cubits/branches_cubit.dart';
import '../navigation/cubits/navigation_cubit.dart';

class DependencyInjector {
  static final DependencyInjector _singleton = DependencyInjector._internal();
  static final Map<Type, dynamic> _deps = {};

  factory DependencyInjector() => _singleton;
  DependencyInjector._internal();

  SupabaseClient get _supabase => Supabase.instance.client;

  // Auth
  AuthDataSource get authDataSource =>
      _deps[AuthDataSource] ??= SupabaseAuthDataSource(_supabase);

  AuthRepository get authRepository =>
      _deps[AuthRepository] ??= AuthRepositoryImpl(authDataSource);

  AuthCubit get authCubit => AuthCubit(authRepository);

  // Orders
  OrdersDataSource get ordersDataSource =>
      _deps[OrdersDataSource] ??= SupabaseOrdersDataSource(_supabase);

  OrdersRepository get ordersRepository =>
      _deps[OrdersRepository] ??= OrdersRepositoryImpl(ordersDataSource);

  OrdersCubit get ordersCubit => OrdersCubit(ordersRepository);

  // Categories
  CategoriesDataSource get categoriesDataSource =>
      _deps[CategoriesDataSource] ??= SupabaseCategoriesDataSource(_supabase);

  CategoriesRepository get categoriesRepository =>
      _deps[CategoriesRepository] ??= CategoriesRepositoryImpl(categoriesDataSource);

  CategoriesCubit get categoriesCubit => CategoriesCubit(categoriesRepository);

  // Products
  ProductsDataSource get productsDataSource =>
      _deps[ProductsDataSource] ??= SupabaseProductsDataSource(_supabase);

  ProductsRepository get productsRepository =>
      _deps[ProductsRepository] ??= ProductsRepositoryImpl(productsDataSource);

  ProductsCubit get productsCubit => ProductsCubit(productsRepository);

  // Customers
  CustomersDataSource get customersDataSource =>
      _deps[CustomersDataSource] ??= SupabaseCustomersDataSource(_supabase);

  CustomersRepository get customersRepository =>
      _deps[CustomersRepository] ??= CustomersRepositoryImpl(customersDataSource);

  CustomersCubit get customersCubit => CustomersCubit(customersRepository);

  // Analytics
  AnalyticsCubit get analyticsCubit => AnalyticsCubit(ordersRepository);

  // Branches
  BranchesDataSource get branchesDataSource =>
      _deps[BranchesDataSource] ??= SupabaseBranchesDataSource(_supabase);

  BranchesRepository get branchesRepository =>
      _deps[BranchesRepository] ??= BranchesRepositoryImpl(branchesDataSource);

  BranchesCubit get branchesCubit => BranchesCubit(branchesRepository);

  // Navigation
  NavigationCubit get navigationCubit =>
      _deps[NavigationCubit] ??= NavigationCubit();
}
