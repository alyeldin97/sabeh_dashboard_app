import '../model/staff_member.dart';

abstract class StaffDataSource {
  Future<List<StaffMember>> getAll();
  Future<StaffMember> create({
    required String phone,
    required String password,
    required Map<String, dynamic> profileData,
  });
  Future<StaffMember> update({required String id, required Map<String, dynamic> data});
  Future<void> delete({required String id});
}
