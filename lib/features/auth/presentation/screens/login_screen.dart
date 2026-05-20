import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/helpers/app_border.dart';
import '../../../../core/styling/colors.dart';
import '../../../../core/styling/padding.dart';
import '../../../../core/styling/text_styles.dart';
import '../cubits/auth_cubit.dart';
import '../../../layout/presentation/screens/layout_screen.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) {
      developer.log('LoginScreen: Form validation failed', name: 'ui.auth');
      return;
    }
    final digits = _phoneCtrl.text.trim().replaceAll(RegExp(r'[^0-9]'), '');
    final fakeEmail = '$digits@sabeh.staff';
    developer.log(
      'LoginScreen: Form validated, submitting sign-in...',
      name: 'ui.auth',
    );
    context.read<AuthCubit>().signIn(
      email: fakeEmail,
      password: _passwordCtrl.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        developer.log(
          'LoginScreen: AuthState changed to ${state.status}',
          name: 'ui.auth',
        );
        if (state.status == AuthStatus.failure && state.errorMessage != null) {
          developer.log(
            'LoginScreen: Sign-in failure detected: ${state.errorMessage}',
            name: 'ui.auth',
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
        }
        if (state.status == AuthStatus.authenticated) {
          developer.log(
            'LoginScreen: Sign-in success, navigating...',
            name: 'ui.auth',
          );
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(LayoutScreen.routeName, (route) => false);
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: AppPadding.screenHV,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 48.h),
                    Center(
                      child: Container(
                        width: 80.r,
                        height: 80.r,
                        decoration: BoxDecoration(
                          color: AppColors.primaryDeep,
                          borderRadius: AppBorderRadius.r16,
                        ),
                        child: Icon(
                          Icons.eco_rounded,
                          color: AppColors.white,
                          size: 40.r,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'Sabeh Dashboard',
                      style: AppTextStyles.heading2(context),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'Staff portal — sign in to continue',
                      style: AppTextStyles.bodySmall(context),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 40.h),
                    TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      validator: (v) => (v == null || v.trim().replaceAll(RegExp(r'[^0-9]'), '').length < 7)
                          ? 'Enter a valid phone number'
                          : null,
                      decoration: _inputDecoration(
                        label: 'Phone Number',
                        icon: Icons.phone_outlined,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      validator: (v) => (v == null || v.isEmpty) ? 'Enter your password' : null,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: _inputDecoration(
                        label: 'Password',
                        icon: Icons.lock_outlined,
                        suffix: GestureDetector(
                          onTap: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          child: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.textLight,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 32.h),
                    SizedBox(
                      height: 52.h,
                      child: ElevatedButton(
                        onPressed: state.status == AuthStatus.loading
                            ? null
                            : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDeep,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppBorderRadius.r12,
                          ),
                          elevation: 0,
                        ),
                        child: state.status == AuthStatus.loading
                            ? SizedBox(
                                width: 22.r,
                                height: 22.r,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.white,
                                ),
                              )
                            : Text('Sign In', style: AppTextStyles.button(context)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTextStyles.label(context),
      prefixIcon: Icon(icon, color: AppColors.primaryMid),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderRadius: AppBorderRadius.r12,
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppBorderRadius.r12,
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppBorderRadius.r12,
        borderSide: BorderSide(color: AppColors.primaryMid, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppBorderRadius.r12,
        borderSide: BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppBorderRadius.r12,
        borderSide: BorderSide(color: AppColors.error, width: 2),
      ),
    );
  }
}
