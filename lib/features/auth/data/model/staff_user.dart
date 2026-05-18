import 'package:equatable/equatable.dart';

enum StaffRole {
  admin,
  manager,
  customerService,
  deliveryManager,
  deliveryUser;

  static StaffRole fromString(String value) {
    switch (value) {
      case 'admin':            return StaffRole.admin;
      case 'manager':          return StaffRole.manager;
      case 'customer_service': return StaffRole.customerService;
      case 'delivery_manager': return StaffRole.deliveryManager;
      case 'delivery_user':    return StaffRole.deliveryUser;
      default:                 return StaffRole.customerService;
    }
  }

  String get value {
    switch (this) {
      case StaffRole.admin:           return 'admin';
      case StaffRole.manager:         return 'manager';
      case StaffRole.customerService: return 'customer_service';
      case StaffRole.deliveryManager: return 'delivery_manager';
      case StaffRole.deliveryUser:    return 'delivery_user';
    }
  }

  bool get isScoped =>
      this == StaffRole.customerService ||
      this == StaffRole.deliveryManager ||
      this == StaffRole.deliveryUser;

  bool get canSeeAllBranches =>
      this == StaffRole.admin || this == StaffRole.manager;

  String get label {
    switch (this) {
      case StaffRole.admin:           return 'Admin';
      case StaffRole.manager:         return 'Manager';
      case StaffRole.customerService: return 'Customer Service';
      case StaffRole.deliveryManager: return 'Delivery Manager';
      case StaffRole.deliveryUser:    return 'Delivery';
    }
  }
}

class StaffUser extends Equatable {
  final String id;
  final String email;
  final String name;
  final StaffRole role;
  final String? branchId;
  final bool isActive;

  const StaffUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.branchId,
    this.isActive = true,
  });

  factory StaffUser.fromJson(Map<String, dynamic> json) => StaffUser(
        id:       json['id'] as String,
        email:    json['email'] as String,
        name:     json['name'] as String,
        role:     StaffRole.fromString(json['role'] as String),
        branchId: json['branch_id'] as String?,
        isActive: json['is_active'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'id':        id,
        'email':     email,
        'name':      name,
        'role':      role.value,
        'branch_id': branchId,
        'is_active': isActive,
      };

  @override
  List<Object?> get props => [id, email, name, role, branchId, isActive];
}
