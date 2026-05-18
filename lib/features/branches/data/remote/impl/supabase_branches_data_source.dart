import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/utils/app_logger.dart';
import '../branches_data_source.dart';
import '../../model/branch_model.dart';

class SupabaseBranchesDataSource implements BranchesDataSource {
  static const _tag = 'BranchesDataSource';
  final SupabaseClient _client;
  SupabaseBranchesDataSource(this._client);

  @override
  Future<List<BranchModel>> getBranches() async {
    AppLogger.net(_tag, 'getBranches');
    try {
      final rows = await _client.from('branches').select().order('name');
      final result = (rows as List)
          .map((r) => BranchModel.fromJson(r as Map<String, dynamic>))
          .toList();
      AppLogger.i(_tag, 'getBranches → ${result.length} branches');
      return result;
    } catch (e, st) {
      AppLogger.e(_tag, 'getBranches failed', e, st);
      rethrow;
    }
  }

  @override
  Future<BranchModel> createBranch({required Map<String, dynamic> data}) async {
    AppLogger.net(_tag, 'createBranch', data['name']);
    try {
      final row = await _client.from('branches').insert(data).select().single();
      final branch = BranchModel.fromJson(row);
      AppLogger.i(_tag, 'createBranch → id=${branch.id}');
      return branch;
    } catch (e, st) {
      AppLogger.e(_tag, 'createBranch failed', e, st);
      rethrow;
    }
  }

  @override
  Future<BranchModel> updateBranch({required String id, required Map<String, dynamic> data}) async {
    AppLogger.net(_tag, 'updateBranch', 'id=$id data=$data');
    try {
      final row = await _client.from('branches').update(data).eq('id', id).select().single();
      final branch = BranchModel.fromJson(row);
      AppLogger.i(_tag, 'updateBranch → id=${branch.id}');
      return branch;
    } catch (e, st) {
      AppLogger.e(_tag, 'updateBranch failed', e, st);
      rethrow;
    }
  }

  @override
  Future<void> deleteBranch({required String id}) async {
    AppLogger.net(_tag, 'deleteBranch', 'id=$id');
    try {
      await _client.from('branches').delete().eq('id', id);
      AppLogger.i(_tag, 'deleteBranch → success');
    } catch (e, st) {
      AppLogger.e(_tag, 'deleteBranch failed', e, st);
      rethrow;
    }
  }
}
