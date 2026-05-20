import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_logger.dart';
import '../../data/model/staff_user.dart';
import '../../data/repo/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  static const _tag = 'AuthCubit';
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(const AuthState()) {
    AppLogger.d(_tag, 'init → checking session');
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await _repository.getCurrentUser();
      if (user != null) {
        AppLogger.i(
          _tag,
          '_checkCurrentUser → authenticated role=${user.role.name}',
        );
        emit(state.copyWith(status: AuthStatus.authenticated, user: user));
      } else {
        AppLogger.i(_tag, '_checkCurrentUser → unauthenticated');
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      }
    } catch (e, st) {
      AppLogger.e(_tag, '_checkCurrentUser failed', e, st);
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    AppLogger.i(_tag, 'signIn email=$email');
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await _repository.signIn(email: email, password: password);
      AppLogger.i(
        _tag,
        'signIn success role=${user.role.name} branchId=${user.branchId}',
      );
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } catch (e, st) {
      AppLogger.e(_tag, 'signIn failed', e, st);
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: _parseError(e),
        ),
      );
    }
  }

  Future<void> signOut() async {
    AppLogger.i(_tag, 'signOut');
    await _repository.signOut();
    emit(state.copyWith(status: AuthStatus.unauthenticated, user: null));
  }

  String _parseError(Object e) {
    final msg = e.toString();
    if (msg.contains('Invalid login credentials')) return 'Invalid phone number or password';
    if (msg.contains('No staff profile found')) return 'No staff profile found. Contact your administrator.';
    if (msg.contains('Email not confirmed')) return 'Please verify your email first';
    if (msg.contains('network')) return 'Network error. Check your connection';
    return 'Sign-in failed. Please try again';
  }
}
