import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/di/dependency_injection.dart';
import 'core/navigation/cubits/navigation_cubit.dart';
import 'core/styling/colors.dart';
import 'core/utils/configurations.dart';
import 'features/analytics/presentation/cubits/analytics_cubit.dart';
import 'features/auth/presentation/cubits/auth_cubit.dart';
import 'features/branches/presentation/cubits/branches_cubit.dart';
import 'features/customers/presentation/cubits/customers_cubit.dart';
import 'features/orders/presentation/cubits/orders_cubit.dart';
import 'routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: AppConfigurations.supabaseUrl,
    anonKey: AppConfigurations.supabaseAnonKey,
  );
  runApp(const SabehDashboardApp());
}

class SabehDashboardApp extends StatelessWidget {
  const SabehDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    final di = DependencyInjector();
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>(create: (_) => di.authCubit),
            BlocProvider<CustomersCubit>(create: (_) => di.customersCubit),
            BlocProvider<OrdersCubit>(create: (_) => di.ordersCubit),
            BlocProvider<AnalyticsCubit>(create: (_) => di.analyticsCubit),
            BlocProvider<BranchesCubit>(create: (_) => di.branchesCubit),
            BlocProvider<NavigationCubit>(create: (_) => di.navigationCubit),
          ],
          child: MaterialApp(
            title: 'Sabeh Dashboard',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primaryDeep,
              ),
              scaffoldBackgroundColor: AppColors.scaffoldBg,
              useMaterial3: true,
            ),
            onGenerateRoute: RouteGenerator.getRoute,
            initialRoute: RouteGenerator.initialRoute,
          ),
        );
      },
    );
  }
}
