import '../model/staff_user.dart';

abstract class AuthDataSource {
  Future<StaffUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<StaffUser?> getCurrentUser();

  Stream<StaffUser?> get authStateChanges;
}
