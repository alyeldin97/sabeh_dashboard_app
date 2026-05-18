import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String id;
  final List<String> branchIds;
  final String name;
  final String? nameAr;
  final String? imageUrl;
  final int sortOrder;
  final bool isActive;

  const Category({
    required this.id,
    this.branchIds = const [],
    required this.name,
    this.nameAr,
    this.imageUrl,
    this.sortOrder = 0,
    this.isActive = true,
  });

  factory Category.fromJson(Map<String, dynamic> j) => Category(
        id:        j['id'] as String,
        branchIds: (j['category_branches'] as List<dynamic>? ?? [])
            .map((b) => (b as Map<String, dynamic>)['branch_id'] as String)
            .toList(),
        name:      j['name'] as String,
        nameAr:    j['name_ar'] as String?,
        imageUrl:  j['image_url'] as String?,
        sortOrder: j['sort_order'] as int? ?? 0,
        isActive:  j['is_active'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'name':       name,
        'name_ar':    nameAr,
        'image_url':  imageUrl,
        'sort_order': sortOrder,
        'is_active':  isActive,
      };

  Category copyWith({
    List<String>? branchIds,
    String? name,
    String? nameAr,
    String? imageUrl,
    int? sortOrder,
    bool? isActive,
  }) =>
      Category(
        id:        id,
        branchIds: branchIds ?? this.branchIds,
        name:      name      ?? this.name,
        nameAr:    nameAr    ?? this.nameAr,
        imageUrl:  imageUrl  ?? this.imageUrl,
        sortOrder: sortOrder ?? this.sortOrder,
        isActive:  isActive  ?? this.isActive,
      );

  @override
  List<Object?> get props => [id, branchIds, name, nameAr, imageUrl, sortOrder, isActive];
}
