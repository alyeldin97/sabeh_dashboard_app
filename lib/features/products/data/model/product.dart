import 'package:equatable/equatable.dart';
import 'product_option.dart';
import 'product_variant.dart';

enum ProductType {
  fixed,
  weight;

  String get value {
    switch (this) {
      case ProductType.fixed:  return 'fixed';
      case ProductType.weight: return 'weight';
    }
  }

  String get label {
    switch (this) {
      case ProductType.fixed:  return 'Fixed Price';
      case ProductType.weight: return 'By Weight';
    }
  }

  static ProductType fromString(String v) {
    switch (v) {
      case 'weight': return ProductType.weight;
      default:       return ProductType.fixed;
    }
  }
}

class Product extends Equatable {
  final String id;
  final List<String> branchIds;
  final List<String> categoryIds;
  final String name;
  final String? description;
  final double price;
  final double? compareAtPrice;
  final ProductType type;
  final bool isActive;
  final bool trackInventory;
  final int sortOrder;
  final List<String> images;
  final int loyaltyPoints;
  final List<ProductOption> options;
  final List<ProductVariant> variants;
  final Map<String, int> inventoryByBranch;

  // Weight-based pricing config
  final int minWeightGrams;
  final int maxWeightGrams;
  final int weightStepGrams;
  final double bulkDiscountPct;

  // Cost of goods
  final double? cogsPercent;

  // Related products
  final List<String> relatedProductIds;

  // Merchandising
  final bool isBestSeller;

  const Product({
    required this.id,
    this.branchIds = const [],
    this.categoryIds = const [],
    required this.name,
    this.description,
    required this.price,
    this.compareAtPrice,
    this.type = ProductType.fixed,
    this.isActive = true,
    this.trackInventory = false,
    this.sortOrder = 0,
    this.images = const [],
    this.loyaltyPoints = 0,
    this.options = const [],
    this.variants = const [],
    this.inventoryByBranch = const {},
    this.minWeightGrams = 250,
    this.maxWeightGrams = 5000,
    this.weightStepGrams = 250,
    this.bulkDiscountPct = 0,
    this.cogsPercent,
    this.relatedProductIds = const [],
    this.isBestSeller = false,
  });

  String? get primaryImage => images.isNotEmpty ? images.first : null;
  bool get hasVariants => variants.isNotEmpty;

  // Price for a given weight in grams (weight-based products only)
  double priceForWeight(int weightGrams) {
    if (type != ProductType.weight) return price;
    final pricePerGram = price / 1000;
    final range = (maxWeightGrams - minWeightGrams).clamp(1, double.maxFinite);
    final ratio = ((weightGrams - minWeightGrams) / range).clamp(0.0, 1.0);
    final discountRate = ratio * (bulkDiscountPct / 100);
    return pricePerGram * weightGrams * (1 - discountRate);
  }

  double get profitMarginPct => cogsPercent == null ? 0 : (100 - cogsPercent!).clamp(0, 100);

  factory Product.fromJson(Map<String, dynamic> j) {
    final opts = (j['product_options'] as List<dynamic>? ?? [])
        .map((o) => ProductOption.fromJson(o as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final varis = (j['product_variants'] as List<dynamic>? ?? [])
        .map((v) => ProductVariant.fromJson(v as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return Product(
      id:             j['id'] as String,
      branchIds:      (j['product_branches'] as List<dynamic>? ?? [])
          .map((b) => (b as Map<String, dynamic>)['branch_id'] as String)
          .toList(),
      categoryIds:    (j['product_categories'] as List<dynamic>? ?? [])
          .map((b) => (b as Map<String, dynamic>)['category_id'] as String)
          .toList(),
      name:           j['name'] as String,
      description:    j['description'] as String?,
      price:          (j['price'] as num).toDouble(),
      compareAtPrice: (j['compare_at_price'] as num?)?.toDouble(),
      type:           ProductType.fromString(j['product_type'] as String? ?? 'fixed'),
      isActive:       j['is_active'] as bool? ?? true,
      trackInventory: j['track_inventory'] as bool? ?? false,
      sortOrder:      j['sort_order'] as int? ?? 0,
      images:         (j['images'] as List<dynamic>?)?.cast<String>() ?? [],
      loyaltyPoints:  j['loyalty_points'] as int? ?? 0,
      options:        opts,
      variants:       varis,
      inventoryByBranch: Map.fromEntries(
        (j['product_inventory'] as List<dynamic>? ?? []).map((inv) {
          final m = inv as Map<String, dynamic>;
          return MapEntry(m['branch_id'] as String, m['quantity'] as int);
        }),
      ),
      minWeightGrams:  j['min_weight_grams'] as int? ?? 250,
      maxWeightGrams:  j['max_weight_grams'] as int? ?? 5000,
      weightStepGrams: j['weight_step_grams'] as int? ?? 250,
      bulkDiscountPct: (j['bulk_discount_pct'] as num?)?.toDouble() ?? 0,
      cogsPercent:     (j['cogs_percent'] as num?)?.toDouble(),
      relatedProductIds: (j['product_related'] as List<dynamic>? ?? [])
          .map((r) => (r as Map<String, dynamic>)['related_product_id'] as String)
          .toList(),
      isBestSeller: j['is_best_seller'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'name':               name,
        'description':        description,
        'price':              price,
        'compare_at_price':   compareAtPrice,
        'product_type':       type.value,
        'is_active':          isActive,
        'track_inventory':    trackInventory,
        'sort_order':         sortOrder,
        'images':             images,
        'loyalty_points':     loyaltyPoints,
        'min_weight_grams':   minWeightGrams,
        'max_weight_grams':   maxWeightGrams,
        'weight_step_grams':  weightStepGrams,
        'bulk_discount_pct':  bulkDiscountPct,
        'cogs_percent':       cogsPercent,
        'is_best_seller':     isBestSeller,
      };

  Product copyWith({
    List<String>? branchIds,
    List<String>? categoryIds,
    String? name,
    String? description,
    double? price,
    double? compareAtPrice,
    ProductType? type,
    bool? isActive,
    bool? trackInventory,
    int? sortOrder,
    List<String>? images,
    int? loyaltyPoints,
    List<ProductOption>? options,
    List<ProductVariant>? variants,
    Map<String, int>? inventoryByBranch,
    int? minWeightGrams,
    int? maxWeightGrams,
    int? weightStepGrams,
    double? bulkDiscountPct,
    double? cogsPercent,
    bool clearCogs = false,
    List<String>? relatedProductIds,
    bool? isBestSeller,
  }) =>
      Product(
        id:                id,
        branchIds:         branchIds         ?? this.branchIds,
        categoryIds:       categoryIds       ?? this.categoryIds,
        name:              name              ?? this.name,
        description:       description       ?? this.description,
        price:             price             ?? this.price,
        compareAtPrice:    compareAtPrice    ?? this.compareAtPrice,
        type:              type              ?? this.type,
        isActive:          isActive          ?? this.isActive,
        trackInventory:    trackInventory    ?? this.trackInventory,
        sortOrder:         sortOrder         ?? this.sortOrder,
        images:            images            ?? this.images,
        loyaltyPoints:     loyaltyPoints     ?? this.loyaltyPoints,
        options:           options           ?? this.options,
        variants:          variants          ?? this.variants,
        inventoryByBranch: inventoryByBranch ?? this.inventoryByBranch,
        minWeightGrams:    minWeightGrams    ?? this.minWeightGrams,
        maxWeightGrams:    maxWeightGrams    ?? this.maxWeightGrams,
        weightStepGrams:   weightStepGrams   ?? this.weightStepGrams,
        bulkDiscountPct:   bulkDiscountPct   ?? this.bulkDiscountPct,
        cogsPercent:       clearCogs ? null  : cogsPercent ?? this.cogsPercent,
        relatedProductIds: relatedProductIds ?? this.relatedProductIds,
        isBestSeller:      isBestSeller      ?? this.isBestSeller,
      );

  @override
  List<Object?> get props => [id, branchIds, categoryIds, name, price, type, isActive, sortOrder, cogsPercent, relatedProductIds];
}
