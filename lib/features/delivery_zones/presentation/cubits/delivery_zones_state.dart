part of 'delivery_zones_cubit.dart';

enum ZonesStatus { initial, loading, loaded, failure }
enum ZoneMutationStatus { idle, saving, failure }

class DeliveryZonesState extends Equatable {
  final List<DeliveryZoneModel> zones;
  final ZonesStatus status;
  final ZoneMutationStatus mutationStatus;
  final String? errorMessage;

  const DeliveryZonesState({
    this.zones = const [],
    this.status = ZonesStatus.initial,
    this.mutationStatus = ZoneMutationStatus.idle,
    this.errorMessage,
  });

  DeliveryZonesState copyWith({
    List<DeliveryZoneModel>? zones,
    ZonesStatus? status,
    ZoneMutationStatus? mutationStatus,
    String? errorMessage,
  }) =>
      DeliveryZonesState(
        zones: zones ?? this.zones,
        status: status ?? this.status,
        mutationStatus: mutationStatus ?? this.mutationStatus,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [zones, status, mutationStatus, errorMessage];
}
