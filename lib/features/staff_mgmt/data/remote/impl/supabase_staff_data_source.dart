import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../../core/utils/app_logger.dart';
import '../../../../../../core/utils/configurations.dart';
import '../staff_data_source.dart';
import '../../model/staff_member.dart';

class SupabaseStaffDataSource implements StaffDataSource {
  static const _tag = 'StaffDataSource';
  final SupabaseClient _client;
  final Dio _dio = Dio();

  SupabaseStaffDataSource(this._client);

  @override
  Future<List<StaffMember>> getAll() async {
    AppLogger.net(_tag, 'getAll');
    try {
      final rows = await _client
          .from('staff_profiles')
          .select()
          .order('created_at', ascending: false);
      final result = (rows as List)
          .map((r) => StaffMember.fromJson(r as Map<String, dynamic>))
          .toList();
      AppLogger.i(_tag, 'getAll → ${result.length} staff members');
      return result;
    } catch (e, st) {
      AppLogger.e(_tag, 'getAll failed', e, st);
      rethrow;
    }
  }

  @override
  Future<StaffMember> create({
    required String phone,
    required String password,
    required Map<String, dynamic> profileData,
  }) async {
    final serviceRoleKey = AppConfigurations.supabaseServiceRoleKey;
    if (serviceRoleKey.isEmpty) {
      throw Exception(
          'Service role key not configured.\n'
          'Add your Supabase service_role key to AppConfigurations.supabaseServiceRoleKey.');
    }

    // Generate a deterministic fake email from the phone digits
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final fakeEmail = '$digits@sabeh.staff';
    AppLogger.net(_tag, 'create', fakeEmail);

    try {
      final authResp = await _dio.post(
        '${AppConfigurations.supabaseUrl}/auth/v1/admin/users',
        options: Options(headers: {
          'Authorization': 'Bearer $serviceRoleKey',
          'apikey': serviceRoleKey,
          'Content-Type': 'application/json',
        }),
        data: {
          'email':         fakeEmail,
          'password':      password,
          'email_confirm': true,
        },
      );
      final uid = authResp.data['id'] as String;
      AppLogger.i(_tag, 'auth user created uid=$uid');

      final row = await _client
          .from('staff_profiles')
          .insert({'id': uid, 'email': fakeEmail, ...profileData})
          .select()
          .single();

      AppLogger.i(_tag, 'staff profile created');
      return StaffMember.fromJson({'email': fakeEmail, ...row});
    } catch (e, st) {
      AppLogger.e(_tag, 'create failed', e, st);
      rethrow;
    }
  }

  @override
  Future<StaffMember> update({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    AppLogger.net(_tag, 'update', 'id=$id');
    try {
      final row = await _client
          .from('staff_profiles')
          .update(data)
          .eq('id', id)
          .select()
          .single();
      AppLogger.i(_tag, 'update success');
      return StaffMember.fromJson(row);
    } catch (e, st) {
      AppLogger.e(_tag, 'update failed', e, st);
      rethrow;
    }
  }

  @override
  Future<void> delete({required String id}) async {
    AppLogger.net(_tag, 'delete', 'id=$id');
    final serviceRoleKey = AppConfigurations.supabaseServiceRoleKey;
    try {
      await _client.from('staff_profiles').delete().eq('id', id);
      if (serviceRoleKey.isNotEmpty) {
        await _dio.delete(
          '${AppConfigurations.supabaseUrl}/auth/v1/admin/users/$id',
          options: Options(headers: {
            'Authorization': 'Bearer $serviceRoleKey',
            'apikey': serviceRoleKey,
          }),
        );
      }
      AppLogger.i(_tag, 'delete success');
    } catch (e, st) {
      AppLogger.e(_tag, 'delete failed', e, st);
      rethrow;
    }
  }
}
