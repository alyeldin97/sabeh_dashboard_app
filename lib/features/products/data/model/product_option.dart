import 'package:equatable/equatable.dart';

class ProductOptionValue extends Equatable {
  final String id;
  final String optionId;
  final String value;
  final int sortOrder;

  const ProductOptionValue({
    required this.id,
    required this.optionId,
    required this.value,
    this.sortOrder = 0,
  });

  factory ProductOptionValue.fromJson(Map<String, dynamic> j) => ProductOptionValue(
        id:        j['id'] as String,
        optionId:  j['option_id'] as String,
        value:     j['value'] as String,
        sortOrder: j['sort_order'] as int? ?? 0,
      );

  @override
  List<Object?> get props => [id, optionId, value, sortOrder];
}

class ProductOption extends Equatable {
  final String id;
  final String productId;
  final String name;
  final int sortOrder;
  final List<ProductOptionValue> values;

  const ProductOption({
    required this.id,
    required this.productId,
    required this.name,
    this.sortOrder = 0,
    this.values = const [],
  });

  factory ProductOption.fromJson(Map<String, dynamic> j) {
    final vals = (j['product_option_values'] as List<dynamic>? ?? [])
        .map((v) => ProductOptionValue.fromJson(v as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return ProductOption(
      id:        j['id'] as String,
      productId: j['product_id'] as String,
      name:      j['name'] as String,
      sortOrder: j['sort_order'] as int? ?? 0,
      values:    vals,
    );
  }

  @override
  List<Object?> get props => [id, productId, name, sortOrder, values];
}
