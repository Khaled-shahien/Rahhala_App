class TripHistoryResponse {
  final bool success;
  final int totalTrips;
  final List<TripHistoryItem> trips;

  const TripHistoryResponse({
    required this.success,
    required this.totalTrips,
    required this.trips,
  });

  factory TripHistoryResponse.fromJson(Map<String, dynamic> json) {
    return TripHistoryResponse(
      success: json['success'] ?? false,
      totalTrips: json['totalTrips'] ?? 0,
      trips: (json['trips'] as List<dynamic>?)
              ?.map((e) => TripHistoryItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class TripHistoryItem {
  final String tripId;
  final String destination;
  final String? countryImage;
  final String country;
  final int numberOfDays;
  final String budgetRange;
  final String totalEstimatedCost;
  final String createdAt;
  final List<String> interests;

  const TripHistoryItem({
    required this.tripId,
    required this.destination,
    required this.countryImage,
    required this.country,
    required this.numberOfDays,
    required this.budgetRange,
    required this.totalEstimatedCost,
    required this.createdAt,
    required this.interests,
  });

  factory TripHistoryItem.fromJson(Map<String, dynamic> json) {
    return TripHistoryItem(
      tripId: json['tripId'] ?? '',
      destination: json['destination'] ?? '',
      countryImage: json['countryImage'],
      country: json['country'] ?? '',
      numberOfDays: json['numberOfDays'] ?? 0,
      budgetRange: json['budgetRange'] ?? '',
      totalEstimatedCost: json['totalEstimatedCost'] ?? '',
      createdAt: json['createdAt'] ?? '',
      interests: (json['interests'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

class TripHistoryDetailResponse {
  final bool success;
  final TripHistoryDetail trip;

  const TripHistoryDetailResponse({
    required this.success,
    required this.trip,
  });

  factory TripHistoryDetailResponse.fromJson(Map<String, dynamic> json) {
    return TripHistoryDetailResponse(
      success: json['success'] ?? false,
      trip: TripHistoryDetail.fromJson(json['trip']),
    );
  }
}

class TripHistoryDetail {
  final String tripId;
  final String destination;
  final String? countryImage;
  final String country;
  final int numberOfDays;
  final String budgetRange;
  final String totalEstimatedCost;
  final String budgetTips;
  final String travelTips;
  final String emergencyContact;
  final String season;
  final String createdAt;
  final List<String> interests;
  final List<TripHistoryDay> days;

  const TripHistoryDetail({
    required this.tripId,
    required this.destination,
    required this.countryImage,
    required this.country,
    required this.numberOfDays,
    required this.budgetRange,
    required this.totalEstimatedCost,
    required this.budgetTips,
    required this.travelTips,
    required this.emergencyContact,
    required this.season,
    required this.createdAt,
    required this.interests,
    required this.days,
  });

  factory TripHistoryDetail.fromJson(Map<String, dynamic> json) {
    return TripHistoryDetail(
      tripId: json['tripId'] ?? '',
      destination: json['destination'] ?? '',
      countryImage: json['countryImage'],
      country: json['country'] ?? '',
      numberOfDays: json['numberOfDays'] ?? 0,
      budgetRange: json['budgetRange'] ?? '',
      totalEstimatedCost: json['totalEstimatedCost'] ?? '',
      budgetTips: json['budgetTips'] ?? '',
      travelTips: json['travelTips'] ?? '',
      emergencyContact: json['emergencycontact'] ?? '',
      season: json['season'] ?? '',
      createdAt: json['createdAt'] ?? '',
      interests: (json['interests'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      days: (json['days'] as List<dynamic>?)
              ?.map((e) => TripHistoryDay.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class TripHistoryDay {
  final int day;
  final String title;
  final String estimatedDayCost;
  final List<TripHistoryActivity> activities;

  const TripHistoryDay({
    required this.day,
    required this.title,
    required this.estimatedDayCost,
    required this.activities,
  });

  factory TripHistoryDay.fromJson(Map<String, dynamic> json) {
    return TripHistoryDay(
      day: json['day'] ?? 0,
      title: json['title'] ?? '',
      estimatedDayCost: json['estimatedDayCost'] ?? '',
      activities: (json['activities'] as List<dynamic>?)
              ?.map((e) => TripHistoryActivity.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class TripHistoryActivity {
  final String time;
  final String place;
  final String? coordinates;
  final String description;
  final String? image;
  final String estimatedCost;
  final List<TripHistoryTransportation> transportation;

  const TripHistoryActivity({
    required this.time,
    required this.place,
    this.coordinates,
    required this.description,
    required this.image,
    required this.estimatedCost,
    this.transportation = const [],
  });

  factory TripHistoryActivity.fromJson(Map<String, dynamic> json) {
    return TripHistoryActivity(
      time: json['time'] ?? '',
      place: json['place'] ?? '',
      coordinates: json['coordinates']?.toString(),
      description: json['description'] ?? '',
      image: json['image'],
      estimatedCost: json['estimatedCost'] ?? '',
      transportation: (json['transportation'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(TripHistoryTransportation.fromJson)
              .toList() ??
          const [],
    );
  }
}

class TripHistoryTransportation {
  final String from;
  final String to;
  final String method;
  final String estimatedCost;

  const TripHistoryTransportation({
    required this.from,
    required this.to,
    required this.method,
    required this.estimatedCost,
  });

  factory TripHistoryTransportation.fromJson(Map<String, dynamic> json) {
    return TripHistoryTransportation(
      from: json['from']?.toString() ?? '',
      to: json['to']?.toString() ?? '',
      method: json['method']?.toString() ?? '',
      estimatedCost: json['estimatedCost']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'from': from,
        'to': to,
        'method': method,
        'estimatedCost': estimatedCost,
      };
}
