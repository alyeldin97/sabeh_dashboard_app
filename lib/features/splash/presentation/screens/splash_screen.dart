import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/styling/images.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../layout/presentation/screens/layout_screen.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = '/splash';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    final cubit = context.read<AuthCubit>();

    await Future.wait([
      Future.delayed(const Duration(seconds: 2)),
      cubit.stream
          .firstWhere((s) => s.status != AuthStatus.loading)
          .catchError((_) => cubit.state),
    ]);
    if (!mounted) return;

    if (cubit.state.status == AuthStatus.authenticated) {
      Navigator.of(context).pushReplacementNamed(LayoutScreen.routeName);
    } else {
      Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.logo),
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}
