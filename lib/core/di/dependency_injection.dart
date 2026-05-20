import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/data/remote/auth_data_source.dart';
import '../../features/auth/data/remote/impl/supabase_auth_data_source.dart';
import '../../features/auth/data/repo/auth_repository.dart';
import '../../features/auth/data/repo/auth_repository_impl.dart';
import '../../features/auth/presentation/cubits/auth_cubit.dart';
import '../../features/expenses/data/remote/expenses_data_source.dart';
import '../../features/expenses/data/remote/impl/supabase_expenses_data_source.dart';
import '../../features/expenses/data/repo/expenses_repository.dart';
import '../../features/expenses/data/repo/expenses_repository_impl.dart';
import '../../features/expenses/presentation/cubits/expenses_cubit.dart';
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
import '../../features/delivery_zones/data/remote/delivery_zones_data_source.dart';
import '../../features/delivery_zones/data/remote/impl/supabase_delivery_zones_data_source.dart';
import '../../features/delivery_zones/data/repo/delivery_zones_repository.dart';
import '../../features/delivery_zones/data/repo/delivery_zones_repository_impl.dart';
import '../../features/delivery_zones/presentation/cubits/delivery_zones_cubit.dart';
import '../../features/app_settings/data/remote/app_settings_data_source.dart';
import '../../features/app_settings/data/remote/impl/supabase_app_settings_data_source.dart';
import '../../features/app_settings/data/repo/app_settings_repository.dart';
import '../../features/app_settings/data/repo/app_settings_repository_impl.dart';
import '../../features/app_settings/presentation/cubits/app_settings_cubit.dart';
import '../../features/loyalty_mgmt/data/remote/loyalty_data_source.dart';
import '../../features/loyalty_mgmt/data/remote/impl/supabase_loyalty_data_source.dart';
import '../../features/loyalty_mgmt/data/repo/loyalty_repository.dart';
import '../../features/loyalty_mgmt/data/repo/loyalty_repository_impl.dart';
import '../../features/loyalty_mgmt/presentation/cubits/loyalty_cubit.dart';
import '../../features/staff_mgmt/data/remote/staff_data_source.dart';
import '../../features/staff_mgmt/data/remote/impl/supabase_staff_data_source.dart';
import '../../features/staff_mgmt/data/repo/staff_repository.dart';
import '../../features/staff_mgmt/data/repo/staff_repository_impl.dart';
import '../../features/staff_mgmt/presentation/cubits/staff_cubit.dart';
import '../../features/promo_codes/data/remote/promo_codes_data_source.dart';
import '../../features/promo_codes/data/remote/impl/supabase_promo_codes_data_source.dart';
import '../../features/promo_codes/data/repo/promo_codes_repository.dart';
import '../../features/promo_codes/data/repo/promo_codes_repository_impl.dart';
import '../../features/promo_codes/presentation/cubits/promo_codes_cubit.dart';
import '../../features/banners/data/remote/banners_data_source.dart';
import '../../features/banners/data/remote/impl/supabase_banners_data_source.dart';
import '../../features/banners/data/repo/banners_repository.dart';
import '../../features/banners/data/repo/banners_repository_impl.dart';
import '../../features/banners/presentation/cubits/banners_cubit.dart';
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

  // Delivery Zones
  DeliveryZonesDataSource get deliveryZonesDataSource =>
      _deps[DeliveryZonesDataSource] ??= SupabaseDeliveryZonesDataSource(_supabase);

  DeliveryZonesRepository get deliveryZonesRepository =>
      _deps[DeliveryZonesRepository] ??= DeliveryZonesRepositoryImpl(deliveryZonesDataSource);

  DeliveryZonesCubit get deliveryZonesCubit => DeliveryZonesCubit(deliveryZonesRepository);

  // App Settings
  AppSettingsDataSource get appSettingsDataSource =>
      _deps[AppSettingsDataSource] ??= SupabaseAppSettingsDataSource(_supabase);

  AppSettingsRepository get appSettingsRepository =>
      _deps[AppSettingsRepository] ??= AppSettingsRepositoryImpl(appSettingsDataSource);

  AppSettingsCubit get appSettingsCubit => AppSettingsCubit(appSettingsRepository);

  // Loyalty Management
  LoyaltyDataSource get loyaltyDataSource =>
      _deps[LoyaltyDataSource] ??= SupabaseLoyaltyDataSource(_supabase);

  LoyaltyRepository get loyaltyRepository =>
      _deps[LoyaltyRepository] ??= LoyaltyRepositoryImpl(loyaltyDataSource);

  LoyaltyCubit get loyaltyCubit => LoyaltyCubit(loyaltyRepository);

  // Staff Management
  StaffDataSource get staffDataSource =>
      _deps[StaffDataSource] ??= SupabaseStaffDataSource(_supabase);

  StaffRepository get staffRepository =>
      _deps[StaffRepository] ??= StaffRepositoryImpl(staffDataSource);

  StaffCubit get staffCubit => StaffCubit(staffRepository);

  // Promo Codes
  PromoCodesDataSource get promoCodesDataSource =>
      _deps[PromoCodesDataSource] ??= SupabasePromoCodesDataSource(_supabase);

  PromoCodesRepository get promoCodesRepository =>
      _deps[PromoCodesRepository] ??= PromoCodesRepositoryImpl(promoCodesDataSource);

  PromoCodesCubit get promoCodesCubit => PromoCodesCubit(promoCodesRepository);

  // Banners
  BannersDataSource get bannersDataSource =>
      _deps[BannersDataSource] ??= SupabaseBannersDataSource(_supabase);

  BannersRepository get bannersRepository =>
      _deps[BannersRepository] ??= BannersRepositoryImpl(bannersDataSource);

  BannersCubit get bannersCubit => BannersCubit(bannersRepository);

  // Expenses
  ExpensesDataSource get expensesDataSource =>
      _deps[ExpensesDataSource] ??= SupabaseExpensesDataSource(_supabase);

  ExpensesRepository get expensesRepo =>
      _deps[ExpensesRepository] ??= ExpensesRepositoryImpl(expensesDataSource);

  ExpensesCubit get expensesCubit => ExpensesCubit(expensesRepo);

  // Navigation
  NavigationCubit get navigationCubit =>
      _deps[NavigationCubit] ??= NavigationCubit();
}
