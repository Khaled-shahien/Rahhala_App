import 'package:equatable/equatable.dart';

class TripPlanResponse extends Equatable {
  final bool success;
  final TripPlan response;
  final int savedId;
  final String? tripId; // New field to store the returned tripId from Save_Trip
  final String? message; // Store the message returned from Save_Trip endpoint
  final Map<String, dynamic>?
      geminiRequest; // Store the request data returned from API

  const TripPlanResponse({
    required this.success,
    required this.response,
    required this.savedId,
    this.tripId,
    this.message,
    this.geminiRequest,
  });

  factory TripPlanResponse.fromJson(Map<String, dynamic> json) {
    // Parse tripData first
    final tripDataJson = json['tripData'] as Map<String, dynamic>? ?? {};

    return TripPlanResponse(
      success: json['success'] ?? false,
      response: TripPlan.fromJson(tripDataJson),
      savedId: json['savedId'] ?? 0,
      tripId: tripDataJson['tripId']?.toString() ?? json['tripId']?.toString(),
      message: json['message']?.toString(),
      geminiRequest: json['geminiRequest'] as Map<String, dynamic>?,
    );
  }

  /// Constructor for parsing Save_Trip response
  factory TripPlanResponse.fromSaveTripResponse(Map<String, dynamic> json) {
    return TripPlanResponse(
      success: json['success'] ?? false,
      response: const TripPlan(
        destination: '',
        days: [],
        totalEstimatedCost: '',
        budgetTips: '',
        travelTips: '',
        emergencyContact: '',
      ),
      savedId: 0,
      tripId: json['tripId']?.toString(),
      message: json['message']?.toString(),
      geminiRequest: null,
    );
  }

  @override
  List<Object?> get props =>
      [success, response, savedId, tripId, message, geminiRequest];
}

class TripPlan extends Equatable {
  final String destination;
  final String? countryImage; // New field for country image
  final List<DailyPlan> days;
  final String totalEstimatedCost;
  final String budgetTips;
  final String travelTips;
  final String emergencyContact;

  const TripPlan({
    required this.destination,
    this.countryImage,
    required this.days,
    required this.totalEstimatedCost,
    required this.budgetTips,
    required this.travelTips,
    required this.emergencyContact,
  });

  factory TripPlan.fromJson(Map<String, dynamic> json) {
    return TripPlan(
      destination: json['destination'] ?? 'Unknown Destination',
      countryImage: json['countryImage']?.toString(),
      days: (json['days'] as List<dynamic>?)
              ?.map((dayJson) => DailyPlan.fromJson(dayJson))
              .toList() ??
          [],
      totalEstimatedCost: json['totalEstimatedCost']?.toString() ?? "0",
      budgetTips: json['budgetTips'] ?? '',
      travelTips: json['travelTips'] ?? '',
      emergencyContact: json['emergencycontact']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [
        destination,
        countryImage,
        days,
        totalEstimatedCost,
        budgetTips,
        travelTips,
        emergencyContact
      ];
}

class DailyPlan extends Equatable {
  final int day;
  final String title;
  final String estimatedDayCost;
  final List<Activity> activities;

  const DailyPlan({
    required this.day,
    required this.title,
    required this.estimatedDayCost,
    required this.activities,
  });

  factory DailyPlan.fromJson(Map<String, dynamic> json) {
    return DailyPlan(
      day: json['day'] ?? 0,
      title: json['title'] ?? 'No Title',
      estimatedDayCost: json['estimatedDayCost']?.toString() ?? "0",
      activities: (json['activities'] as List<dynamic>?)
              ?.map((activityJson) => Activity.fromJson(activityJson))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [day, title, estimatedDayCost, activities];
}

class Activity extends Equatable {
  final String time;
  final String place;
  final String description;
  final String estimatedCost;
  final String? image;
  final List<Transportation> transportation;

  const Activity({
    required this.time,
    required this.place,
    required this.description,
    required this.estimatedCost,
    this.image,
    required this.transportation,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      time: json['time'] ?? 'N/A',
      place: json['place'] ?? 'Unknown Place',
      description: json['description'] ?? '',
      estimatedCost: json['estimatedCost']?.toString() ?? "0",
      image: json['image']?.toString(),
      transportation: (json['transportation'] as List<dynamic>?)
              ?.map((tJson) => Transportation.fromJson(tJson))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props =>
      [time, place, description, estimatedCost, image, transportation];
}

class Transportation extends Equatable {
  final String from;
  final String to;
  final String method;
  final String estimatedCost;

  const Transportation({
    required this.from,
    required this.to,
    required this.method,
    required this.estimatedCost,
  });

  factory Transportation.fromJson(Map<String, dynamic> json) {
    return Transportation(
      from: json['from'] ?? 'N/A',
      to: json['to'] ?? 'N/A',
      method: json['method'] ?? 'N/A',
      estimatedCost: json['estimatedCost']?.toString() ?? "0",
    );
  }

  @override
  List<Object?> get props => [from, to, method, estimatedCost];
}
