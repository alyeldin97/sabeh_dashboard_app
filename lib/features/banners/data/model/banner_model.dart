import 'package:equatable/equatable.dart';

enum BannerActionType {
  none,
  url,
  product,
  collection;

  static BannerActionType fromString(String? v) {
    switch (v) {
      case 'url':        return BannerActionType.url;
      case 'product':    return BannerActionType.product;
      case 'collection': return BannerActionType.collection;
      default:           return BannerActionType.none;
    }
  }

  String get value {
    switch (this) {
      case BannerActionType.none:       return 'none';
      case BannerActionType.url:        return 'url';
      case BannerActionType.product:    return 'product';
      case BannerActionType.collection: return 'collection';
    }
  }

  String get label {
    switch (this) {
      case BannerActionType.none:       return 'No Action';
      case BannerActionType.url:        return 'Open URL';
      case BannerActionType.product:    return 'Go to Product';
      case BannerActionType.collection: return 'Go to Collection';
    }
  }
}

class BannerModel extends Equatable {
  final String id;
  final String imageUrl;
  final String? title;
  final bool isActive;
  final int sortOrder;
  final BannerActionType actionType;
  final String? actionUrl;
  final String? actionProductId;
  final String? actionCollectionId;
  final DateTime? startDate;
  final DateTime? endDate;

  const BannerModel({
    required this.id,
    required this.imageUrl,
    this.title,
    this.isActive = true,
    this.sortOrder = 0,
    this.actionType = BannerActionType.none,
    this.actionUrl,
    this.actionProductId,
    this.actionCollectionId,
    this.startDate,
    this.endDate,
  });

  factory BannerModel.fromJson(Map<String, dynamic> j) => BannerModel(
        id:                 j['id'] as String,
        imageUrl:           j['image_url'] as String,
        title:              j['title'] as String?,
        isActive:           j['is_active'] as bool? ?? true,
        sortOrder:          j['sort_order'] as int? ?? 0,
        actionType:         BannerActionType.fromString(j['action_type'] as String?),
        actionUrl:          j['link'] as String?,
        actionProductId:    j['action_product_id'] as String?,
        actionCollectionId: j['action_collection_id'] as String?,
        startDate:          j['start_date'] != null ? DateTime.tryParse(j['start_date'] as String) : null,
        endDate:            j['end_date'] != null ? DateTime.tryParse(j['end_date'] as String) : null,
      );

  Map<String, dynamic> toJson() => {
        'image_url':             imageUrl,
        'title':                 title,
        'is_active':             isActive,
        'sort_order':            sortOrder,
        'action_type':           actionType.value,
        'link':                  actionType == BannerActionType.url ? actionUrl : null,
        'action_product_id':     actionType == BannerActionType.product ? actionProductId : null,
        'action_collection_id':  actionType == BannerActionType.collection ? actionCollectionId : null,
        'start_date':            startDate?.toIso8601String(),
        'end_date':              endDate?.toIso8601String(),
      };

  BannerModel copyWith({
    String? imageUrl,
    String? title,
    bool? isActive,
    int? sortOrder,
    BannerActionType? actionType,
    String? actionUrl,
    String? actionProductId,
    String? actionCollectionId,
    DateTime? startDate,
    DateTime? endDate,
  }) =>
      BannerModel(
        id:                 id,
        imageUrl:           imageUrl           ?? this.imageUrl,
        title:              title              ?? this.title,
        isActive:           isActive           ?? this.isActive,
        sortOrder:          sortOrder          ?? this.sortOrder,
        actionType:         actionType         ?? this.actionType,
        actionUrl:          actionUrl          ?? this.actionUrl,
        actionProductId:    actionProductId    ?? this.actionProductId,
        actionCollectionId: actionCollectionId ?? this.actionCollectionId,
        startDate:          startDate          ?? this.startDate,
        endDate:            endDate            ?? this.endDate,
      );

  @override
  List<Object?> get props =>
      [id, imageUrl, title, isActive, sortOrder, actionType, actionUrl, actionProductId, actionCollectionId];
}
