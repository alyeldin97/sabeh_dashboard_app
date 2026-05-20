import '../../../auth/data/model/staff_user.dart';
import '../model/staff_member.dart';

abstract class StaffRepository {
  Future<List<StaffMember>> getAll();
  Future<StaffMember> create({
    required String phone,
    required String password,
    required String name,
    required StaffRole role,
    required List<String> branchIds,
  });
  Future<StaffMember> update({
    required String id,
    required String name,
    required StaffRole role,
    required List<String> branchIds,
    required bool isActive,
    String? phone,
  });
  Future<void> delete({required String id});
}
