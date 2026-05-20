import 'package:equatable/equatable.dart';
import '../../../auth/data/model/staff_user.dart';

class StaffMember extends Equatable {
  final String id;
  final String email;
  final String name;
  final StaffRole role;
  final List<String> branchIds;
  final bool isActive;
  final String? phone;
  final DateTime? createdAt;

  String? get branchId => branchIds.isNotEmpty ? branchIds.first : null;

  const StaffMember({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.branchIds = const [],
    this.isActive = true,
    this.phone,
    this.createdAt,
  });

  factory StaffMember.fromJson(Map<String, dynamic> j) {
    // Prefer branch_ids array; fall back to legacy branch_id single value
    final rawIds = j['branch_ids'];
    List<String> branchIds;
    if (rawIds is List && rawIds.isNotEmpty) {
      branchIds = rawIds.whereType<String>().toList();
    } else {
      final single = j['branch_id'] as String?;
      branchIds = single != null && single.isNotEmpty ? [single] : [];
    }
    return StaffMember(
      id:        j['id'] as String,
      email:     j['email'] as String? ?? '',
      name:      j['name'] as String,
      role:      StaffRole.fromString(j['role'] as String),
      branchIds: branchIds,
      isActive:  j['is_active'] as bool? ?? true,
      phone:     j['phone'] as String?,
      createdAt: j['created_at'] != null
          ? DateTime.tryParse(j['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'email':      email,
        'name':       name,
        'role':       role.value,
        'branch_ids': branchIds,
        'branch_id':  branchIds.isNotEmpty ? branchIds.first : null,
        'is_active':  isActive,
        'phone':      phone,
      };

  StaffMember copyWith({
    String? id,
    String? email,
    String? name,
    StaffRole? role,
    List<String>? branchIds,
    bool? isActive,
    String? phone,
    DateTime? createdAt,
  }) =>
      StaffMember(
        id:        id        ?? this.id,
        email:     email     ?? this.email,
        name:      name      ?? this.name,
        role:      role      ?? this.role,
        branchIds: branchIds ?? this.branchIds,
        isActive:  isActive  ?? this.isActive,
        phone:     phone     ?? this.phone,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  List<Object?> get props =>
      [id, email, name, role, branchIds, isActive, phone, createdAt];
}
