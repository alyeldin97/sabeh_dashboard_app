part of 'branches_cubit.dart';

enum BranchesStatus { initial, loading, success, failure }
enum BranchMutationStatus { idle, saving, deleting, success, failure }

class BranchesState extends Equatable {
  final BranchesStatus status;
  final BranchMutationStatus mutationStatus;
  final List<BranchModel> branches;
  final String? errorMessage;

  const BranchesState({
    this.status = BranchesStatus.initial,
    this.mutationStatus = BranchMutationStatus.idle,
    this.branches = const [],
    this.errorMessage,
  });

  BranchesState copyWith({
    BranchesStatus? status,
    BranchMutationStatus? mutationStatus,
    List<BranchModel>? branches,
    String? errorMessage,
  }) =>
      BranchesState(
        status:         status         ?? this.status,
        mutationStatus: mutationStatus ?? this.mutationStatus,
        branches:       branches       ?? this.branches,
        errorMessage:   errorMessage   ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [status, mutationStatus, branches, errorMessage];
}
