class NearbyPlaceModel {
  final String id;
  final String name;
  final String primaryCategory;
  final List<String> categories;
  final String vicinity;
  final double latitude;
  final double longitude;
  final double distanceMeters;
  final String distanceText;
  final double? rating;
  final bool? openNow;
  final String? photoUrl;

  const NearbyPlaceModel({
    required this.id,
    required this.name,
    required this.primaryCategory,
    required this.categories,
    required this.vicinity,
    required this.latitude,
    required this.longitude,
    required this.distanceMeters,
    required this.distanceText,
    this.rating,
    this.openNow,
    this.photoUrl,
  });

  factory NearbyPlaceModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'] ?? {};
    return NearbyPlaceModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      primaryCategory: json['primaryCategory'] ?? 'Other',
      categories: List<String>.from(json['categories'] ?? []),
      vicinity: json['vicinity'] ?? '',
      latitude: (location['lat'] ?? 0).toDouble(),
      longitude: (location['lng'] ?? 0).toDouble(),
      distanceMeters: (json['distanceMeters'] ?? 0).toDouble(),
      distanceText: json['distanceText'] ?? '',
      rating: json['rating'] != null ? (json['rating']).toDouble() : null,
      openNow: json['openNow'],
      photoUrl: json['photoUrl'],
    );
  }

  String get formattedDistance => distanceText.isNotEmpty
      ? distanceText
      : distanceMeters >= 1000
          ? '${(distanceMeters / 1000).toStringAsFixed(1)} Km away'
          : '${distanceMeters.toInt()} m away';
}
