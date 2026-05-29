import '../model/promo_code_model.dart';
import '../remote/promo_codes_data_source.dart';
import 'promo_codes_repository.dart';

class PromoCodesRepositoryImpl implements PromoCodesRepository {
  final PromoCodesDataSource _dataSource;
  PromoCodesRepositoryImpl(this._dataSource);

  @override
  Future<List<PromoCodeModel>> getAll() => _dataSource.getAll();

  @override
  Future<PromoCodeModel> create({
    required String code,
    required PromoType type,
    required double discountValue,
    required double minOrder,
    int? maxUses,
    DateTime? expiresAt,
    DateTime? startsAt,
    String? description,
    required int maxUsesPerUser,
    int? cashbackExpiryDays,
  }) =>
      _dataSource.create(data: {
        'code':                 code.toUpperCase(),
        'discount_type':        type.value,
        'discount_value':       discountValue,
        'min_order':            minOrder,
        'max_uses':             maxUses,
        'expires_at':           expiresAt?.toIso8601String(),
        'starts_at':            startsAt?.toIso8601String(),
        'is_active':            true,
        'description':          description,
        'max_uses_per_user':    maxUsesPerUser,
        'cashback_expiry_days': cashbackExpiryDays,
      });

  @override
  Future<PromoCodeModel> update({
    required String id,
    required String code,
    required PromoType type,
    required double discountValue,
    required double minOrder,
    int? maxUses,
    DateTime? expiresAt,
    DateTime? startsAt,
    required bool isActive,
    String? description,
    required int maxUsesPerUser,
    int? cashbackExpiryDays,
  }) =>
      _dataSource.update(id: id, data: {
        'code':                 code.toUpperCase(),
        'discount_type':        type.value,
        'discount_value':       discountValue,
        'min_order':            minOrder,
        'max_uses':             maxUses,
        'expires_at':           expiresAt?.toIso8601String(),
        'starts_at':            startsAt?.toIso8601String(),
        'is_active':            isActive,
        'description':          description,
        'max_uses_per_user':    maxUsesPerUser,
        'cashback_expiry_days': cashbackExpiryDays,
      });

  @override
  Future<void> delete({required String id}) => _dataSource.delete(id: id);
}
