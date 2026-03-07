class ImageSearchResponse {
  final bool success;
  final List<String> labels;
  final List<PlaceResult> places;

  const ImageSearchResponse({
    required this.success,
    required this.labels,
    required this.places,
  });

  factory ImageSearchResponse.fromJson(Map<String, dynamic> json) {
    return ImageSearchResponse(
      success: json['success'] ?? false,
      labels: (json['labels'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      places: (json['places'] as List<dynamic>?)
              ?.map((e) => PlaceResult.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class PlaceResult {
  final String name;
  final double rating;
  final String photoUrl;
  final String address;

  const PlaceResult({
    required this.name,
    required this.rating,
    required this.photoUrl,
    required this.address,
  });

  factory PlaceResult.fromJson(Map<String, dynamic> json) {
    return PlaceResult(
      name: json['name'] ?? '',
      rating: double.tryParse(json['rating'].toString()) ?? 0.0,
      //rating: (json['rating'] ?? 0).toDouble(),
      photoUrl: json['photoUrl'] ?? '',
      address: json['address'] ?? '',
    );
  }
}
