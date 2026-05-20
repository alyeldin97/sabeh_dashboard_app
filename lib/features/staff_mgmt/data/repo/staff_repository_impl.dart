import '../../../auth/data/model/staff_user.dart';
import '../model/staff_member.dart';
import '../remote/staff_data_source.dart';
import 'staff_repository.dart';

class StaffRepositoryImpl implements StaffRepository {
  final StaffDataSource _dataSource;
  StaffRepositoryImpl(this._dataSource);

  @override
  Future<List<StaffMember>> getAll() => _dataSource.getAll();

  @override
  Future<StaffMember> create({
    required String phone,
    required String password,
    required String name,
    required StaffRole role,
    required List<String> branchIds,
  }) =>
      _dataSource.create(
        phone: phone,
        password: password,
        profileData: {
          'name':       name,
          'role':       role.value,
          'phone':      phone,
          'branch_ids': branchIds,
          'branch_id':  branchIds.isNotEmpty ? branchIds.first : null,
          'is_active':  true,
        },
      );

  @override
  Future<StaffMember> update({
    required String id,
    required String name,
    required StaffRole role,
    required List<String> branchIds,
    required bool isActive,
    String? phone,
  }) =>
      _dataSource.update(id: id, data: {
        'name':       name,
        'role':       role.value,
        'branch_ids': branchIds,
        'branch_id':  branchIds.isNotEmpty ? branchIds.first : null,
        'is_active':  isActive,
        'phone':      phone,
      });

  @override
  Future<void> delete({required String id}) => _dataSource.delete(id: id);
}
