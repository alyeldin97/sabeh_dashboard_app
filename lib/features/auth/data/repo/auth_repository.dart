import '../model/staff_user.dart';

abstract class AuthRepository {
  Future<StaffUser> signIn({required String email, required String password});
  Future<void> signOut();
  Future<StaffUser?> getCurrentUser();
  Stream<StaffUser?> get authStateChanges;
}
