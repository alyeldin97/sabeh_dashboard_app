import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/utils/app_logger.dart';
import '../../model/staff_user.dart';
import '../auth_data_source.dart';

class SupabaseAuthDataSource implements AuthDataSource {
  static const _tag = 'AuthDataSource';

  final SupabaseClient _client;
  SupabaseAuthDataSource(this._client);

  @override
  Future<StaffUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    AppLogger.net(_tag, 'signInWithEmail', email);
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final uid = response.user?.id;
      if (uid == null) throw Exception('Sign-in failed: no user returned');

      AppLogger.i(_tag, 'auth success uid=$uid, fetching staff profile');
      try {
        final profileData = await _client
            .from('staff_profiles')
            .select()
            .eq('id', uid)
            .single();
        AppLogger.i(_tag, 'staff profile → role=${profileData['role']}');
        return StaffUser.fromJson({
          'id':    uid,
          'email': response.user!.email ?? email,
          ...profileData,
        });
      } catch (profileErr) {
        // Auth succeeded but no staff profile — sign out to avoid a dangling session.
        await _client.auth.signOut();
        AppLogger.e(_tag, 'no staff profile for uid=$uid, signed out', profileErr);
        throw Exception('No staff profile found. Contact your administrator.');
      }
    } catch (e, st) {
      AppLogger.e(_tag, 'signInWithEmail failed', e, st);
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    AppLogger.i(_tag, 'signOut');
    await _client.auth.signOut();
  }

  @override
  Future<StaffUser?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    AppLogger.d(_tag, 'getCurrentUser uid=${user?.id}');
    if (user == null) return null;
    try {
      final profileData = await _client
          .from('staff_profiles')
          .select()
          .eq('id', user.id)
          .single();
      AppLogger.i(_tag, 'getCurrentUser → role=${profileData['role']}');
      return StaffUser.fromJson({
        'id':    user.id,
        'email': user.email ?? '',
        ...profileData,
      });
    } catch (e, st) {
      AppLogger.e(_tag, 'getCurrentUser profile fetch failed', e, st);
      return null;
    }
  }

  @override
  Stream<StaffUser?> get authStateChanges =>
      _client.auth.onAuthStateChange.asyncMap((event) async {
        AppLogger.d(_tag, 'authStateChange event=${event.event.name}');
        final user = event.session?.user;
        if (user == null) return null;
        try {
          final profileData = await _client
              .from('staff_profiles')
              .select()
              .eq('id', user.id)
              .single();
          return StaffUser.fromJson({
            'id':    user.id,
            'email': user.email ?? '',
            ...profileData,
          });
        } catch (e) {
          AppLogger.w(_tag, 'authStateChange profile fetch failed', e);
          return null;
        }
      });
}
