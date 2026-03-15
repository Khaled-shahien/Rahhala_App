import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:rahhala_app/features/ai_recommendation/data/models/trip_plan_model.dart';

void main() {
  group('Save Trip API Response Tests', () {
    // Sample Save_Trip response from the new endpoint
    const String saveTripResponse = '''
{
    "success": true,
    "message": "Trip saved successfully.",
    "tripId": "20e11d3f-c7e0-4127-ab26-c2a057a3e4b9"
}
''';

    test('should parse Save_Trip response successfully', () {
      // Arrange
      final Map<String, dynamic> jsonResponse = jsonDecode(saveTripResponse);

      // Act
      final result = TripPlanResponse.fromSaveTripResponse(jsonResponse);

      // Assert
      expect(result.success, true);
      expect(result.message, 'Trip saved successfully.');
      expect(result.tripId, '20e11d3f-c7e0-4127-ab26-c2a057a3e4b9');
      expect(result.geminiRequest, isNull);
    });

    test('should handle Save_Trip response with missing message', () {
      // Arrange
      final jsonResponse = {
        'success': true,
        'tripId': 'test-trip-id-123',
      };

      // Act
      final result = TripPlanResponse.fromSaveTripResponse(jsonResponse);

      // Assert
      expect(result.success, true);
      expect(result.message, isNull);
      expect(result.tripId, 'test-trip-id-123');
    });

    test('should handle Save_Trip response with null tripId', () {
      // Arrange
      final jsonResponse = {
        'success': false,
        'message': 'Failed to save trip',
      };

      // Act
      final result = TripPlanResponse.fromSaveTripResponse(jsonResponse);

      // Assert
      expect(result.success, false);
      expect(result.message, 'Failed to save trip');
      expect(result.tripId, isNull);
    });

    test('should parse complete Ask_Gemini response with all fields', () {
      // Arrange
      const String askGeminiResponse = '''
{
    "success": true,
    "tripData": {
        "destination": "Egypt",
        "countryImage": "https://images.pexels.com/photos/35506463/pexels-photo-35506463.jpeg?auto=compress&cs=tinysrgb&h=650&w=940",
        "days": [
            {
                "day": 1,
                "title": "Ancient Wonders",
                "estimatedDayCost": "4000 EGP",
                "activities": [
                    {
                        "time": "Morning",
                        "place": "Pyramids of Giza",
                        "description": "Explore the pyramids",
                        "estimatedCost": "500 EGP",
                        "transportation": [
                            {
                                "from": "Hotel in Cairo",
                                "to": "Pyramids of Giza",
                                "method": "Private Car",
                                "estimatedCost": "0"
                            }
                        ],
                        "image": "https://images.pexels.com/photos/18904667/pexels-photo-18904667.jpeg"
                    }
                ]
            }
        ],
        "totalEstimatedCost": "7500 EGP",
        "budgetTips": "Opt for local eateries",
        "travelTips": "Stay hydrated",
        "emergencycontact": "Police: 122",
        "tripId": "00000000-0000-0000-0000-000000000000"
    },
    "geminiRequest": {
        "country": "Egypt",
        "numberOfDays": 2,
        "budget": "5000-8000",
        "interestTypes": ["Culture", "Food"],
        "season": "summer"
    }
}
''';

      // Act
      final Map<String, dynamic> jsonResponse = jsonDecode(askGeminiResponse);
      final result = TripPlanResponse.fromJson(jsonResponse);

      // Assert
      expect(result.success, true);
      expect(result.response.destination, 'Egypt');
      expect(
        result.response.countryImage,
        'https://images.pexels.com/photos/35506463/pexels-photo-35506463.jpeg?auto=compress&cs=tinysrgb&h=650&w=940',
      );
      expect(result.response.days.length, 1);
      expect(result.response.totalEstimatedCost, '7500 EGP');
      expect(result.tripId, '00000000-0000-0000-0000-000000000000');
      expect(result.geminiRequest, isA<Map<String, dynamic>>());
      expect(result.geminiRequest!['country'], 'Egypt');
      expect(result.geminiRequest!['numberOfDays'], 2);
    });

    test('should verify Activity model parses image field correctly', () {
      // Arrange
      final activityJson = {
        'time': 'Morning',
        'place': 'Pyramids of Giza',
        'description': 'Explore the pyramids',
        'estimatedCost': '500 EGP',
        'transportation': [],
        'image': 'https://example.com/image.jpg',
      };

      // Act
      final activity = Activity.fromJson(activityJson);

      // Assert
      expect(activity.image, 'https://example.com/image.jpg');
    });

    test('should handle activity with null image gracefully', () {
      // Arrange
      final activityJson = {
        'time': 'Afternoon',
        'place': 'Museum',
        'description': 'Visit museum',
        'estimatedCost': '300 EGP',
        'transportation': [],
      };

      // Act
      final activity = Activity.fromJson(activityJson);

      // Assert
      expect(activity.image, isNull);
    });
  });
}
