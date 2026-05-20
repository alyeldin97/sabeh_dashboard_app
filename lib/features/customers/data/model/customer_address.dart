class CustomerAddress {
  final String id;
  final String customerId;
  final String? label;
  final String? street;
  final String? building;
  final String? floor;
  final String? apartment;
  final String? landmark;
  final bool isDefault;

  const CustomerAddress({
    required this.id,
    required this.customerId,
    this.label,
    this.street,
    this.building,
    this.floor,
    this.apartment,
    this.landmark,
    this.isDefault = false,
  });

  factory CustomerAddress.fromJson(Map<String, dynamic> j) => CustomerAddress(
        id:         j['id'] as String,
        customerId: j['customer_id'] as String,
        label:      j['label'] as String?,
        street:     j['street'] as String?,
        building:   j['building'] as String?,
        floor:      j['floor'] as String?,
        apartment:  j['apartment'] as String?,
        landmark:   j['landmark'] as String?,
        isDefault:  (j['is_default'] as bool?) ?? false,
      );

  String get displayTitle => label ?? street ?? 'Address';

  String get displaySubtitle {
    final parts = <String>[
      if (street != null) street!,
      if (building != null) 'Bldg $building',
      if (floor != null) 'Floor $floor',
      if (apartment != null) 'Apt $apartment',
      if (landmark != null) landmark!,
    ];
    return parts.join(', ');
  }

  String get fullAddress {
    final parts = <String>[
      if (label != null) label!,
      if (street != null) street!,
      if (building != null) 'Bldg $building',
      if (floor != null) 'Floor $floor',
      if (apartment != null) 'Apt $apartment',
    ];
    return parts.join(', ');
  }
}
