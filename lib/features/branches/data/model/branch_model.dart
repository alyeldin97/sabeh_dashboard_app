import 'package:equatable/equatable.dart';

class BranchModel extends Equatable {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final double coverageRadius;
  final bool isActive;

  const BranchModel({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.coverageRadius,
    this.isActive = true,
  });

  factory BranchModel.fromJson(Map<String, dynamic> j) => BranchModel(
        id:             j['id'] as String,
        name:           j['name'] as String,
        lat:            (j['lat'] as num).toDouble(),
        lng:            (j['lng'] as num).toDouble(),
        coverageRadius: (j['coverage_radius'] as num?)?.toDouble() ?? 10.0,
        isActive:       j['is_active'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'name':            name,
        'lat':             lat,
        'lng':             lng,
        'coverage_radius': coverageRadius,
        'is_active':       isActive,
      };

  BranchModel copyWith({
    String? name,
    double? lat,
    double? lng,
    double? coverageRadius,
    bool? isActive,
  }) =>
      BranchModel(
        id:             id,
        name:           name            ?? this.name,
        lat:            lat             ?? this.lat,
        lng:            lng             ?? this.lng,
        coverageRadius: coverageRadius  ?? this.coverageRadius,
        isActive:       isActive        ?? this.isActive,
      );

  @override
  List<Object?> get props => [id, name, lat, lng, coverageRadius, isActive];
}
