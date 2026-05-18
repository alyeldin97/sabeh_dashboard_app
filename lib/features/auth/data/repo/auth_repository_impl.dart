import '../model/staff_user.dart';
import '../remote/auth_data_source.dart';
import 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Future<StaffUser> signIn({required String email, required String password}) =>
      _dataSource.signInWithEmailAndPassword(email: email, password: password);

  @override
  Future<void> signOut() => _dataSource.signOut();

  @override
  Future<StaffUser?> getCurrentUser() => _dataSource.getCurrentUser();

  @override
  Stream<StaffUser?> get authStateChanges => _dataSource.authStateChanges;
}
