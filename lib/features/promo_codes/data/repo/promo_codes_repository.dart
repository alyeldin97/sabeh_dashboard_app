import '../model/promo_code_model.dart';

abstract class PromoCodesRepository {
  Future<List<PromoCodeModel>> getAll();
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
  });
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
  });
  Future<void> delete({required String id});
}
