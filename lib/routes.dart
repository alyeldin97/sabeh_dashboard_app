import 'package:flutter/material.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/layout/presentation/screens/layout_screen.dart';

class RouteGenerator {
  static const String initialRoute = LoginScreen.routeName;

  static Route<dynamic> getRoute(RouteSettings settings) {
    switch (settings.name) {
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
