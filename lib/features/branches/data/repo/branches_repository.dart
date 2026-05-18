import '../model/branch_model.dart';

abstract class BranchesRepository {
  Future<List<BranchModel>> getBranches();
  Future<BranchModel> createBranch({required Map<String, dynamic> data});
  Future<BranchModel> updateBranch({required String id, required Map<String, dynamic> data});
  Future<void> deleteBranch({required String id});
}
