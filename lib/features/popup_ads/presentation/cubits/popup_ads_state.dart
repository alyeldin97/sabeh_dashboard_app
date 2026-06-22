import 'package:equatable/equatable.dart';
import '../../data/model/popup_ad_model.dart';

enum PopupAdsStatus { initial, loading, loaded, failure }

class PopupAdsState extends Equatable {
  final PopupAdsStatus status;
  final List<PopupAdModel> ads;
  final String? errorMessage;

  const PopupAdsState({
    this.status = PopupAdsStatus.initial,
    this.ads = const [],
    this.errorMessage,
  });

  PopupAdsState copyWith({
    PopupAdsStatus? status,
    List<PopupAdModel>? ads,
    String? errorMessage,
  }) =>
      PopupAdsState(
        status:       status       ?? this.status,
        ads:          ads          ?? this.ads,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [status, ads, errorMessage];
}
