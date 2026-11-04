import 'nearby_place.dart';

class NearbyResponseModel {
  final double centerLat;
  final double centerLng;
  final int count;
  final List<NearbyPlaceModel> results;
  final Map<String, List<NearbyPlaceModel>> sections;
  final List<String> availableCategories;

  NearbyResponseModel({
    required this.centerLat,
    required this.centerLng,
    required this.count,
    required this.results,
    required this.sections,
    required this.availableCategories,
  });

  factory NearbyResponseModel.fromJson(Map<String, dynamic> json) {
    final center = json['center'] ?? {};
    final rawResults = json['results'] as List? ?? [];
    final rawSections = json['sections'] as Map<String, dynamic>? ?? {};

    final sections = <String, List<NearbyPlaceModel>>{};
    rawSections.forEach((key, value) {
      sections[key] =
          (value as List).map((e) => NearbyPlaceModel.fromJson(e)).toList();
    });

    return NearbyResponseModel(
      centerLat: (center['lat'] ?? 0).toDouble(),
      centerLng: (center['lng'] ?? 0).toDouble(),
      count: json['count'] ?? 0,
      results: rawResults.map((e) => NearbyPlaceModel.fromJson(e)).toList(),
      sections: sections,
      availableCategories: List<String>.from(json['availableCategories'] ?? []),
    );
  }
}
