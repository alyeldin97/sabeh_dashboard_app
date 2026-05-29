import 'package:flutter/material.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/layout/presentation/screens/layout_screen.dart';
import 'features/splash/presentation/screens/splash_screen.dart';

class RouteGenerator {
  static const String initialRoute = SplashScreen.routeName;

  static Route<dynamic> getRoute(RouteSettings settings) {
    switch (settings.name) {
      case SplashScreen.routeName:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case LoginScreen.routeName:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case LayoutScreen.routeName:
        return MaterialPageRoute(builder: (_) => const LayoutScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}
