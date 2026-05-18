import 'package:equatable/equatable.dart';

class ProductVariant extends Equatable {
  final String id;
  final String productId;
  final double price;
  final double? compareAtPrice;
  final bool isActive;
  final int sortOrder;
  final List<String> optionValueIds;
  final Map<String, int> inventoryByBranch;

  const ProductVariant({
    required this.id,
    required this.productId,
    required this.price,
    this.compareAtPrice,
    this.isActive = true,
    this.sortOrder = 0,
    this.optionValueIds = const [],
    this.inventoryByBranch = const {},
  });

  factory ProductVariant.fromJson(Map<String, dynamic> j) => ProductVariant(
        id:             j['id'] as String,
        productId:      j['product_id'] as String,
        price:          (j['price'] as num).toDouble(),
        compareAtPrice: (j['compare_at_price'] as num?)?.toDouble(),
        isActive:       j['is_active'] as bool? ?? true,
        sortOrder:      j['sort_order'] as int? ?? 0,
        optionValueIds: (j['variant_option_values'] as List<dynamic>? ?? [])
            .map((v) => (v as Map<String, dynamic>)['option_value_id'] as String)
            .toList(),
        inventoryByBranch: Map.fromEntries(
          (j['variant_inventory'] as List<dynamic>? ?? []).map((inv) {
            final m = inv as Map<String, dynamic>;
            return MapEntry(m['branch_id'] as String, m['quantity'] as int);
          }),
        ),
      );

  @override
  List<Object?> get props => [id, productId, price, compareAtPrice, isActive, sortOrder, optionValueIds];
}
