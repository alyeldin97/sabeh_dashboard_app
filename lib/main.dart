import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:sabeh_dashboard_app/l10n/app_localizations.dart';
import 'core/di/dependency_injection.dart';
import 'core/locale/locale_cubit.dart';
import 'core/navigation/cubits/navigation_cubit.dart';
import 'core/services/staff_fcm_service.dart';
import 'core/styling/colors.dart';
import 'core/utils/configurations.dart';
import 'features/analytics/presentation/cubits/analytics_cubit.dart';
import 'features/auth/presentation/cubits/auth_cubit.dart';
import 'features/branches/presentation/cubits/branches_cubit.dart';
import 'features/customers/presentation/cubits/customers_cubit.dart';
import 'features/delivery_zones/presentation/cubits/delivery_zones_cubit.dart';
import 'features/orders/presentation/cubits/orders_cubit.dart';
import 'features/products/presentation/cubits/products_cubit.dart';
import 'routes.dart';

// Needed to handle background FCM on Android
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage _) async {
  // TODO: add `options: DefaultFirebaseOptions.currentPlatform` after flutterfire configure
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: import firebase_options.dart and pass DefaultFirebaseOptions.currentPlatform
  // once you run: flutterfire configure
  bool firebaseReady = false;
  try {
    if (!kIsWeb) {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      firebaseReady = true;
    }
  } catch (e) {
    // ignore: avoid_print
    print('[StaffFCMService] Firebase init FAILED — run `flutterfire configure`. Error: $e');
  }

  await Supabase.initialize(
    url: AppConfigurations.supabaseUrl,
    anonKey: AppConfigurations.supabaseAnonKey,
  );

  final localeCubit = LocaleCubit();
  await localeCubit.init();

  if (firebaseReady) await StaffFCMService.instance.init();
  runApp(SabehDashboardApp(localeCubit: localeCubit));
}

class SabehDashboardApp extends StatelessWidget {
  const SabehDashboardApp({super.key, required this.localeCubit});

  final LocaleCubit localeCubit;

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
            BlocProvider<LocaleCubit>.value(value: localeCubit),
            BlocProvider<AuthCubit>(create: (_) => di.authCubit),
            BlocProvider<CustomersCubit>(create: (_) => di.customersCubit),
            BlocProvider<OrdersCubit>(create: (_) => di.ordersCubit),
            BlocProvider<AnalyticsCubit>(create: (_) => di.analyticsCubit),
            BlocProvider<BranchesCubit>(create: (_) => di.branchesCubit),
            BlocProvider<DeliveryZonesCubit>(
              create: (_) => di.deliveryZonesCubit,
            ),
            BlocProvider<ProductsCubit>(create: (_) => di.productsCubit),
            BlocProvider<NavigationCubit>(create: (_) => di.navigationCubit),
          ],
          child: BlocListener<AuthCubit, AuthState>(
            listener: (_, state) {
              if (state.status == AuthStatus.authenticated) {
                StaffFCMService.instance.syncTokenForStaff();
              } else if (state.status == AuthStatus.unauthenticated) {
                StaffFCMService.instance.deleteToken();
              }
            },
            child: BlocBuilder<LocaleCubit, Locale>(
              builder: (context, locale) => MaterialApp(
                title: 'Sabeh Dashboard',
                debugShowCheckedModeBanner: false,
                locale: locale,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
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
            ),
          ),
        );
      },
    );
  }
}
