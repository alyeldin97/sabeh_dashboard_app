import '../model/branch_model.dart';
import '../remote/branches_data_source.dart';
import 'branches_repository.dart';

class BranchesRepositoryImpl implements BranchesRepository {
  final BranchesDataSource _ds;
  BranchesRepositoryImpl(this._ds);

  @override
  Future<List<BranchModel>> getBranches() => _ds.getBranches();

  @override
  Future<BranchModel> createBranch({required Map<String, dynamic> data}) =>
      _ds.createBranch(data: data);

  @override
  Future<BranchModel> updateBranch({required String id, required Map<String, dynamic> data}) =>
      _ds.updateBranch(id: id, data: data);

  @override
  Future<void> deleteBranch({required String id}) => _ds.deleteBranch(id: id);
}
