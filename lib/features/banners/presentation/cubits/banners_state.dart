part of 'banners_cubit.dart';

enum BannersStatus { initial, loading, success, failure }
enum BannerMutationStatus { idle, saving, deleting, success, failure }

class BannersState extends Equatable {
  final BannersStatus status;
  final BannerMutationStatus mutationStatus;
  final List<BannerModel> banners;
  final String? errorMessage;

  const BannersState({
    this.status = BannersStatus.initial,
    this.mutationStatus = BannerMutationStatus.idle,
    this.banners = const [],
    this.errorMessage,
  });

  BannersState copyWith({
    BannersStatus? status,
    BannerMutationStatus? mutationStatus,
    List<BannerModel>? banners,
    String? errorMessage,
  }) =>
      BannersState(
        status:         status         ?? this.status,
        mutationStatus: mutationStatus ?? this.mutationStatus,
        banners:        banners        ?? this.banners,
        errorMessage:   errorMessage   ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [status, mutationStatus, banners, errorMessage];
}
