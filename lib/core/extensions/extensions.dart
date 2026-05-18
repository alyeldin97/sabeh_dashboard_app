import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/cubits/auth_cubit.dart';

extension BuildContextX on BuildContext {
  AuthCubit get authCubit => read<AuthCubit>();
}
