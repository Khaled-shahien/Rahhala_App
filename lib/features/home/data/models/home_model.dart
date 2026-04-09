class HomeResponse {
  final bool success;
  final List<PlaceModel> places;

  HomeResponse({required this.success, required this.places});

  factory HomeResponse.fromJson(Map<String, dynamic> json) {
    return HomeResponse(
      success: json['success'] ?? false,
      places: (json['youMightAlsoLike'] as List)
          .map((item) => PlaceModel.fromJson(item))
          .toList(),
    );
  }
}

class PlaceModel {
  final String id;
  final String name;
  final String country;
  final String imageUrl;
  final bool isFavourite;

  PlaceModel({
    required this.id,
    required this.name,
    required this.country,
    required this.imageUrl,
    required this.isFavourite,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    return PlaceModel(
      id: json['id'],
      name: json['name'],
      country: json['country'],
      imageUrl: json['imageUrl'],
      isFavourite: json['isFavourite'] ?? false,
    );
  }
}

class PlaceDetailsResponse {
  final bool success;
  final PlaceDetailsModel place;

  PlaceDetailsResponse({required this.success, required this.place});

  factory PlaceDetailsResponse.fromJson(Map<String, dynamic> json) =>
      PlaceDetailsResponse(
        success: json["success"],
        place: PlaceDetailsModel.fromJson(json["place"]),
      );
}

class PlaceDetailsModel {
  final String id, name, country, description, imageUrl;
  final List<SubItemModel> hotels;
  final List<SubItemModel> restaurants;
  final List<ReviewModel> reviews;
  final RatingSummaryModel ratingSummary;

  PlaceDetailsModel({
    required this.id,
    required this.name,
    required this.country,
    required this.description,
    required this.imageUrl,
    required this.hotels,
    required this.restaurants,
    required this.reviews,
    required this.ratingSummary,
  });

  factory PlaceDetailsModel.fromJson(Map<String, dynamic> json) =>
      PlaceDetailsModel(
        id: json["id"],
        name: json["name"],
        country: json["country"],
        description: json["description"],
        imageUrl: json["imageUrl"],
        hotels: List<SubItemModel>.from(
            json["hotels"].map((x) => SubItemModel.fromJson(x))),
        restaurants: List<SubItemModel>.from(
            json["restaurants"].map((x) => SubItemModel.fromJson(x))),
        reviews: List<ReviewModel>.from(
            json["reviews"].map((x) => ReviewModel.fromJson(x))),
        ratingSummary: RatingSummaryModel.fromJson(json["ratingSummary"]),
      );
}

class SubItemModel {
  final String id, name, imageUrl;
  final double rating;

  SubItemModel(
      {required this.id,
      required this.name,
      required this.imageUrl,
      required this.rating});

  factory SubItemModel.fromJson(Map<String, dynamic> json) => SubItemModel(
        id: json["id"],
        name: json["name"],
        imageUrl: json["imageUrl"],
        rating: (json["rating"] ?? 0).toDouble(),
      );
}

class ReviewModel {
  final String id, userName, comment, createdAt;
  final double rating;

  ReviewModel(
      {required this.id,
      required this.userName,
      required this.comment,
      required this.createdAt,
      required this.rating});

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
        id: (json["id"] ?? '').toString(),
        userName: (json["userName"] ?? '').toString(),
        comment: (json["comment"] ?? '').toString(),
        createdAt: (json["createdAt"] ?? '').toString(),
        rating: (json["rating"] ?? 0).toDouble(),
      );
}

class RatingSummaryModel {
  final double average;
  final int totalReviews;
  final Map<int, double> distribution;

  RatingSummaryModel(
      {required this.average,
      required this.totalReviews,
      required this.distribution});

  factory RatingSummaryModel.fromJson(Map<String, dynamic> json) {
    Map<int, double> dist = {};
    for (var item in json["distribution"]) {
      dist[item["star"]] = (item["percentage"] / 100).toDouble();
    }
    return RatingSummaryModel(
      average: (json["average"] ?? 0).toDouble(),
      totalReviews: json["totalReviews"],
      distribution: dist,
    );
  }
}

class ReviewRequest {
  final String comment;
  final int rating;

  ReviewRequest({required this.comment, required this.rating});

  Map<String, dynamic> toJson() => {
        "comment": comment,
        "rating": rating,
      };
}
