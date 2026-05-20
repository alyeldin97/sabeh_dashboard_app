part of 'promo_codes_cubit.dart';

enum PromoCodesStatus { initial, loading, success, failure }
enum PromoMutationStatus { idle, saving, deleting, success, failure }

class PromoCodesState extends Equatable {
  final PromoCodesStatus status;
  final PromoMutationStatus mutationStatus;
  final List<PromoCodeModel> codes;
  final String? errorMessage;

  const PromoCodesState({
    this.status = PromoCodesStatus.initial,
    this.mutationStatus = PromoMutationStatus.idle,
    this.codes = const [],
    this.errorMessage,
  });

  PromoCodesState copyWith({
    PromoCodesStatus? status,
    PromoMutationStatus? mutationStatus,
    List<PromoCodeModel>? codes,
    String? errorMessage,
  }) =>
      PromoCodesState(
        status:         status         ?? this.status,
        mutationStatus: mutationStatus ?? this.mutationStatus,
        codes:          codes          ?? this.codes,
        errorMessage:   errorMessage   ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [status, mutationStatus, codes, errorMessage];
}
