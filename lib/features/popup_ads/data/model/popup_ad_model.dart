import 'package:equatable/equatable.dart';

enum PopupDisplayFrequency {
  everySession,
  oncePerDay,
  onceEver;

  String toDbValue() => switch (this) {
        everySession => 'every_session',
        oncePerDay   => 'once_per_day',
        onceEver     => 'once_ever',
      };

  static PopupDisplayFrequency fromDbValue(String? v) => switch (v) {
        'once_per_day' => oncePerDay,
        'once_ever'    => onceEver,
        _              => everySession,
      };
}

class PopupAdModel extends Equatable {
  final String id;
  final String title;
  final String? imageUrl;
  final String? bodyText;
  final String? buttonText;
  final String? buttonUrl;
  final bool isActive;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final DateTime? countdownEndsAt;
  final PopupDisplayFrequency displayFrequency;
  final DateTime createdAt;

  const PopupAdModel({
    required this.id,
    required this.title,
    this.imageUrl,
    this.bodyText,
    this.buttonText,
    this.buttonUrl,
    this.isActive = true,
    this.startsAt,
    this.endsAt,
    this.countdownEndsAt,
    this.displayFrequency = PopupDisplayFrequency.everySession,
    required this.createdAt,
  });

  factory PopupAdModel.fromJson(Map<String, dynamic> j) => PopupAdModel(
        id:               j['id'] as String,
        title:            j['title'] as String,
        imageUrl:         j['image_url'] as String?,
        bodyText:         j['body_text'] as String?,
        buttonText:       j['button_text'] as String?,
        buttonUrl:        j['button_url'] as String?,
        isActive:         j['is_active'] as bool? ?? true,
        startsAt:         j['starts_at'] != null ? DateTime.tryParse(j['starts_at'] as String) : null,
        endsAt:           j['ends_at'] != null ? DateTime.tryParse(j['ends_at'] as String) : null,
        countdownEndsAt:  j['countdown_ends_at'] != null ? DateTime.tryParse(j['countdown_ends_at'] as String) : null,
        displayFrequency: PopupDisplayFrequency.fromDbValue(j['display_frequency'] as String?),
        createdAt:        DateTime.parse(j['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'title':             title,
        'image_url':         imageUrl,
        'body_text':         bodyText,
        'button_text':       buttonText,
        'button_url':        buttonUrl,
        'is_active':           isActive,
        'starts_at':           startsAt?.toIso8601String(),
        'ends_at':             endsAt?.toIso8601String(),
        'countdown_ends_at':   countdownEndsAt?.toIso8601String(),
        'display_frequency':   displayFrequency.toDbValue(),
      };

  PopupAdModel copyWith({
    String? title,
    String? imageUrl,
    String? bodyText,
    String? buttonText,
    String? buttonUrl,
    bool? isActive,
    DateTime? startsAt,
    DateTime? endsAt,
    DateTime? countdownEndsAt,
    PopupDisplayFrequency? displayFrequency,
    bool clearStartsAt = false,
    bool clearEndsAt = false,
    bool clearCountdownEndsAt = false,
    bool clearImage = false,
    bool clearButton = false,
  }) =>
      PopupAdModel(
        id:               id,
        title:            title     ?? this.title,
        imageUrl:         clearImage  ? null : imageUrl  ?? this.imageUrl,
        bodyText:         bodyText  ?? this.bodyText,
        buttonText:       clearButton ? null : buttonText ?? this.buttonText,
        buttonUrl:        clearButton ? null : buttonUrl  ?? this.buttonUrl,
        isActive:         isActive  ?? this.isActive,
        startsAt:         clearStartsAt ? null : startsAt ?? this.startsAt,
        endsAt:           clearEndsAt   ? null : endsAt   ?? this.endsAt,
        countdownEndsAt:  clearCountdownEndsAt ? null : countdownEndsAt ?? this.countdownEndsAt,
        displayFrequency: displayFrequency ?? this.displayFrequency,
        createdAt:        createdAt,
      );

  @override
  List<Object?> get props => [id, title, imageUrl, isActive, startsAt, endsAt, countdownEndsAt, displayFrequency];
}
