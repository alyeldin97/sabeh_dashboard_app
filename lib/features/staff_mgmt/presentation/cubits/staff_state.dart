part of 'staff_cubit.dart';

enum StaffStatus { initial, loading, success, failure }
enum StaffMutationStatus { idle, saving, deleting, success, failure }

class StaffState extends Equatable {
  final StaffStatus status;
  final StaffMutationStatus mutationStatus;
  final List<StaffMember> members;
  final String? errorMessage;

  const StaffState({
    this.status = StaffStatus.initial,
    this.mutationStatus = StaffMutationStatus.idle,
    this.members = const [],
    this.errorMessage,
  });

  StaffState copyWith({
    StaffStatus? status,
    StaffMutationStatus? mutationStatus,
    List<StaffMember>? members,
    String? errorMessage,
  }) =>
      StaffState(
        status:         status         ?? this.status,
        mutationStatus: mutationStatus ?? this.mutationStatus,
        members:        members        ?? this.members,
        errorMessage:   errorMessage   ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [status, mutationStatus, members, errorMessage];
}
