bool _asBool(dynamic value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    return normalized == 'true' ||
        normalized == '1' ||
        normalized == 'yes' ||
        normalized == 'success';
  }
  return fallback;
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim()) ?? fallback;
  return fallback;
}

double _asDouble(dynamic value, {double fallback = 0}) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim()) ?? fallback;
  return fallback;
}

String _asString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  final stringValue = value.toString();
  return stringValue.isEmpty ? fallback : stringValue;
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

List<dynamic> _asList(dynamic value) {
  if (value is List) return value;
  return const <dynamic>[];
}

class HomeResponse {
  final bool success;
  final int page;
  final int pageSize;
  final List<PlaceModel> places;

  HomeResponse({
    required this.success,
    required this.page,
    required this.pageSize,
    required this.places,
  });

  factory HomeResponse.fromJson(Map<String, dynamic> json) {
    return HomeResponse(
      success: _asBool(json['success']),
      page: _asInt(json['page'], fallback: 1),
      pageSize: _asInt(json['pageSize'], fallback: 8),
      places: _asList(json['youMightAlsoLike'])
          .map(_asMap)
          .where((item) => item.isNotEmpty)
          .map(PlaceModel.fromJson)
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
      id: _asString(json['id']),
      name: _asString(json['name'], fallback: 'Unknown place'),
      country: _asString(json['country']),
      imageUrl: _asString(json['imageUrl']),
      isFavourite: _asBool(json['isFavourite']),
    );
  }

  PlaceModel copyWith({
    String? id,
    String? name,
    String? country,
    String? imageUrl,
    bool? isFavourite,
  }) {
    return PlaceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      country: country ?? this.country,
      imageUrl: imageUrl ?? this.imageUrl,
      isFavourite: isFavourite ?? this.isFavourite,
    );
  }
}

class FavouritesResponse {
  final bool success;
  final int total;
  final List<FavouriteModel> favourites;

  FavouritesResponse({
    required this.success,
    required this.total,
    required this.favourites,
  });

  factory FavouritesResponse.fromJson(Map<String, dynamic> json) {
    return FavouritesResponse(
      success: _asBool(json['success']),
      total: _asInt(json['total']),
      favourites: _asList(json['favourites'])
          .map(_asMap)
          .where((item) => item.isNotEmpty)
          .map(FavouriteModel.fromJson)
          .toList(),
    );
  }
}

class FavouriteModel {
  final String id;
  final String name;
  final String country;
  final String imageUrl;
  final double rating;
  final String createdAt;

  FavouriteModel({
    required this.id,
    required this.name,
    required this.country,
    required this.imageUrl,
    required this.rating,
    required this.createdAt,
  });

  factory FavouriteModel.fromJson(Map<String, dynamic> json) {
    return FavouriteModel(
      id: _asString(json['id']),
      name: _asString(json['name'], fallback: 'Unknown place'),
      country: _asString(json['country']),
      imageUrl: _asString(json['imageUrl']),
      rating: _asDouble(json['rating']),
      createdAt: _asString(json['createdAt']),
    );
  }
}

class PlaceDetailsResponse {
  final bool success;
  final PlaceDetailsModel place;

  PlaceDetailsResponse({required this.success, required this.place});

  factory PlaceDetailsResponse.fromJson(Map<String, dynamic> json) =>
      PlaceDetailsResponse(
        success: _asBool(json["success"]),
        place: PlaceDetailsModel.fromJson(_asMap(json["place"])),
      );
}

class PlaceDetailsModel {
  final String id, name, country, description, imageUrl;
  final List<SubItemModel> hotels;
  final List<SubItemModel> restaurants;
  final List<SubItemModel> activities;
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
    required this.activities,
    required this.reviews,
    required this.ratingSummary,
  });

  factory PlaceDetailsModel.fromJson(Map<String, dynamic> json) =>
      PlaceDetailsModel(
        id: _asString(json["id"]),
        name: _asString(json["name"], fallback: 'Unknown place'),
        country: _asString(json["country"]),
        description: _asString(json["description"]),
        imageUrl: _asString(json["imageUrl"]),
        hotels: _asList(json["hotels"])
            .map(_asMap)
            .where((x) => x.isNotEmpty)
            .map(SubItemModel.fromJson)
            .toList(),
        restaurants: _asList(json["restaurants"])
            .map(_asMap)
            .where((x) => x.isNotEmpty)
            .map(SubItemModel.fromJson)
            .toList(),
        activities: _asList(json["activities"])
            .map(_asMap)
            .where((x) => x.isNotEmpty)
            .map(SubItemModel.fromJson)
            .toList(),
        reviews: _asList(json["reviews"])
            .map(_asMap)
            .where((x) => x.isNotEmpty)
            .map(ReviewModel.fromJson)
            .toList(),
        ratingSummary:
            RatingSummaryModel.fromJson(_asMap(json["ratingSummary"])),
      );
}

class SubItemModel {
  final String id, name, imageUrl;
  final double rating;

  SubItemModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.rating,
  });

  factory SubItemModel.fromJson(Map<String, dynamic> json) => SubItemModel(
        id: _asString(json["id"]),
        name: _asString(json["name"], fallback: 'Unknown item'),
        imageUrl: _asString(json["imageUrl"]),
        rating: _asDouble(json["rating"]),
      );
}

class ReviewModel {
  final String id;
  final String userName;
  final String comment;
  final String createdAt;
  final double rating;
  final String? userImageUrl;
  final String? userId;

  ReviewModel({
    required this.id,
    required this.userName,
    required this.comment,
    required this.createdAt,
    required this.rating,
    this.userImageUrl,
    this.userId,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
        id: _asString(json["id"]),
        userName: _asString(json["userName"], fallback: 'User'),
        comment: _asString(json["comment"]),
        createdAt: _asString(json["createdAt"]),
        rating: _asDouble(json["rating"]),
        userImageUrl: _asString(json["userImageUrl"]).isEmpty
            ? null
            : _asString(json["userImageUrl"]),
        userId: _asString(
          json["userId"] ?? json["userID"] ?? _asMap(json["user"])["id"],
        ).isEmpty
            ? null
            : _asString(
                json["userId"] ?? json["userID"] ?? _asMap(json["user"])["id"],
              ),
      );
}

class RatingSummaryModel {
  final double average;
  final int totalReviews;
  final Map<int, double> distribution;

  RatingSummaryModel({
    required this.average,
    required this.totalReviews,
    required this.distribution,
  });

  factory RatingSummaryModel.fromJson(Map<String, dynamic> json) {
    Map<int, double> dist = {};
    final rawDistribution = json["distribution"];
    if (rawDistribution is Map) {
      rawDistribution.forEach((key, value) {
        final star = _asInt(key);
        if (star > 0) {
          final percentage = _asDouble(value);
          dist[star] = percentage > 1 ? percentage / 100 : percentage;
        }
      });
    } else {
      for (final item in _asList(rawDistribution)) {
        final map = _asMap(item);
        final star = _asInt(map["star"]);
        if (star > 0) {
          dist[star] = _asDouble(map["percentage"]) / 100;
        }
      }
    }
    return RatingSummaryModel(
      average: _asDouble(json["average"]),
      totalReviews: _asInt(json["totalReviews"]),
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
