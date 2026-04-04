import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:rahhala_app/features/ai_recommendation/data/models/trip_plan_model.dart';

void main() {
  group('TripPlanResponse Model Tests', () {
    // Sample response from the API based on your provided example
    const String sampleApiResponse = '''
{
    "success": true,
    "tripData": {
        "destination": "Egypt",
        "countryImage": "https://images.pexels.com/photos/35506463/pexels-photo-35506463.jpeg?auto=compress&cs=tinysrgb&h=650&w=940",
        "days": [
            {
                "day": 1,
                "title": "Ancient Wonders and Nile Delights",
                "estimatedDayCost": "4000 EGP",
                "activities": [
                    {
                        "time": "Morning",
                        "place": "Pyramids of Giza and Sphinx",
                        "description": "Explore the iconic Pyramids of Giza, marvel at the Great Sphinx, and learn about ancient Egyptian history. Consider a camel ride for a classic experience.",
                        "estimatedCost": "500 EGP",
                        "transportation": [
                            {
                                "from": "Hotel in Cairo",
                                "to": "Pyramids of Giza",
                                "method": "Private Car",
                                "estimatedCost": "0"
                            }
                        ],
                        "image": "https://images.pexels.com/photos/18904667/pexels-photo-18904667.jpeg?auto=compress&cs=tinysrgb&h=650&w=940"
                    },
                    {
                        "time": "Afternoon",
                        "place": "Egyptian Museum (Tahrir Square)",
                        "description": "Immerse yourself in a vast collection of ancient Egyptian antiquities, including the treasures of Tutankhamun.",
                        "estimatedCost": "300 EGP",
                        "transportation": [
                            {
                                "from": "Pyramids of Giza",
                                "to": "Egyptian Museum",
                                "method": "Taxi",
                                "estimatedCost": "150 EGP"
                            }
                        ],
                        "image": "https://images.pexels.com/photos/4353815/pexels-photo-4353815.jpeg?auto=compress&cs=tinysrgb&h=650&w=940"
                    },
                    {
                        "time": "Evening",
                        "place": "Nile Dinner Cruise",
                        "description": "Enjoy a delicious Egyptian dinner while sailing on the Nile River, accompanied by traditional music and belly dancing.",
                        "estimatedCost": "1500 EGP",
                        "transportation": [
                            {
                                "from": "Egyptian Museum",
                                "to": "Nile Cruise Dock",
                                "method": "Taxi",
                                "estimatedCost": "100 EGP"
                            }
                        ],
                        "image": "https://images.pexels.com/photos/12607742/pexels-photo-12607742.jpeg?auto=compress&cs=tinysrgb&h=650&w=940"
                    }
                ]
            },
            {
                "day": 2,
                "title": "Mediterranean Charm and Coastal Breezes",
                "estimatedDayCost": "3500 EGP",
                "activities": [
                    {
                        "time": "Morning",
                        "place": "Alexandria Corniche and Bibliotheca Alexandrina",
                        "description": "Stroll along the picturesque Corniche, enjoying the sea breeze. Visit the modern Bibliotheca Alexandrina, a modern marvel honoring the ancient Library of Alexandria.",
                        "estimatedCost": "400 EGP",
                        "transportation": [
                            {
                                "from": "Hotel in Cairo",
                                "to": "Alexandria (High-speed Train)",
                                "method": "Train",
                                "estimatedCost": "0"
                            }
                        ],
                        "image": "https://images.pexels.com/photos/16714089/pexels-photo-16714089.jpeg?auto=compress&cs=tinysrgb&h=650&w=940"
                    },
                    {
                        "time": "Afternoon",
                        "place": "Qaitbay Citadel and Underwater Museum (if available/accessible)",
                        "description": "Explore the historic Qaitbay Citadel, a 15th-century fortress built on the site of the ancient Lighthouse of Alexandria. If accessible, explore its underwater museum showcasing ancient artifacts.",
                        "estimatedCost": "300 EGP",
                        "transportation": [
                            {
                                "from": "Bibliotheca Alexandrina",
                                "to": "Qaitbay Citadel",
                                "method": "Taxi",
                                "estimatedCost": "100 EGP"
                            }
                        ],
                        "image": "https://images.pexels.com/photos/14795810/pexels-photo-14795810.jpeg?auto=compress&cs=tinysrgb&h=650&w=940"
                    },
                    {
                        "time": "Evening",
                        "place": "Seafood Dinner at a Local Restaurant",
                        "description": "Indulge in fresh, delicious seafood at one of Alexandria's many waterfront restaurants, enjoying the evening sea breeze.",
                        "estimatedCost": "1500 EGP",
                        "transportation": [
                            {
                                "from": "Qaitbay Citadel",
                                "to": "Restaurant",
                                "method": "Walking",
                                "estimatedCost": "0"
                            }
                        ],
                        "image": "https://images.pexels.com/photos/35421075/pexels-photo-35421075.jpeg?auto=compress&cs=tinysrgb&h=650&w=940"
                    }
                ]
            }
        ],
        "totalEstimatedCost": "7500 EGP",
        "budgetTips": "Opt for local eateries and street food for delicious and affordable meals. Consider shared taxis or public transport for shorter distances. Book flights and accommodation in advance for better rates, especially during peak summer season. Purchase a Cairo Pass if you plan to visit multiple archaeological sites.",
        "travelTips": "Stay hydrated and wear light, breathable clothing due to the summer heat. Use sunscreen, hats, and sunglasses. Dress respectfully when visiting religious sites. Learn a few basic Arabic phrases; it will be appreciated. Be mindful of local customs and traditions.",
        "emergencycontact": "Police: 122, Ambulance: 123, Tourist Police: 126, Fire Department: 180",
        "tripId": "00000000-0000-0000-0000-000000000000"
    },
    "geminiRequest": {
        "country": "Egypt",
        "numberOfDays": 2,
        "budget": "5000-8000",
        "interestTypes": [
            "Culture",
            "Food",
            "Beach"
        ],
        "season": "summer"
    }
}
''';

    test('should parse complete API response successfully', () {
      // Arrange
      final Map<String, dynamic> jsonResponse = jsonDecode(sampleApiResponse);

      // Act
      final result = TripPlanResponse.fromJson(jsonResponse);

      // Assert
      expect(result.success, true);
      expect(result.response.destination, 'Egypt');
      expect(
        result.response.countryImage,
        'https://images.pexels.com/photos/35506463/pexels-photo-35506463.jpeg?auto=compress&cs=tinysrgb&h=650&w=940',
      );
      expect(result.response.days.length, 2);
      expect(result.response.totalEstimatedCost, '7500 EGP');
      expect(result.response.budgetTips.isNotEmpty, true);
      expect(result.response.travelTips.isNotEmpty, true);
      expect(result.response.emergencyContact.isNotEmpty, true);
    });

    test('should parse first day activities correctly', () {
      // Arrange
      final Map<String, dynamic> jsonResponse = jsonDecode(sampleApiResponse);

      // Act
      final result = TripPlanResponse.fromJson(jsonResponse);
      final firstDay = result.response.days.first;

      // Assert
      expect(firstDay.day, 1);
      expect(
        firstDay.title,
        'Ancient Wonders and Nile Delights',
      );
      expect(firstDay.estimatedDayCost, '4000 EGP');
      expect(firstDay.activities.length, 3);

      // First activity
      final firstActivity = firstDay.activities.first;
      expect(firstActivity.time, 'Morning');
      expect(firstActivity.place, 'Pyramids of Giza and Sphinx');
      expect(firstActivity.description.isNotEmpty, true);
      expect(firstActivity.estimatedCost, '500 EGP');
      expect(
        firstActivity.image,
        'https://images.pexels.com/photos/18904667/pexels-photo-18904667.jpeg?auto=compress&cs=tinysrgb&h=650&w=940',
      );
      expect(firstActivity.transportation.length, 1);
      expect(firstActivity.transportation.first.from, 'Hotel in Cairo');
      expect(firstActivity.transportation.first.to, 'Pyramids of Giza');
      expect(firstActivity.transportation.first.method, 'Private Car');
    });

    test('should parse second day activities correctly', () {
      // Arrange
      final Map<String, dynamic> jsonResponse = jsonDecode(sampleApiResponse);

      // Act
      final result = TripPlanResponse.fromJson(jsonResponse);
      final secondDay = result.response.days[1];

      // Assert
      expect(secondDay.day, 2);
      expect(
        secondDay.title,
        'Mediterranean Charm and Coastal Breezes',
      );
      expect(secondDay.estimatedDayCost, '3500 EGP');
      expect(secondDay.activities.length, 3);

      // Last activity
      final lastActivity = secondDay.activities.last;
      expect(lastActivity.time, 'Evening');
      expect(lastActivity.place, 'Seafood Dinner at a Local Restaurant');
      expect(lastActivity.description.isNotEmpty, true);
      expect(lastActivity.estimatedCost, '1500 EGP');
      expect(
        lastActivity.image,
        'https://images.pexels.com/photos/35421075/pexels-photo-35421075.jpeg?auto=compress&cs=tinysrgb&h=650&w=940',
      );
      expect(lastActivity.transportation.length, 1);
      expect(lastActivity.transportation.first.method, 'Walking');
    });

    test('should parse geminiRequest from response', () {
      // Arrange
      final Map<String, dynamic> jsonResponse = jsonDecode(sampleApiResponse);

      // Act
      final result = TripPlanResponse.fromJson(jsonResponse);

      // Assert
      expect(result.geminiRequest, isNotNull);
      expect(result.geminiRequest!['country'], 'Egypt');
      expect(result.geminiRequest!['numberOfDays'], 2);
      expect(result.geminiRequest!['budget'], '5000-8000');
      expect(result.geminiRequest!['interestTypes'], isA<List>());
      expect(result.geminiRequest!['season'], 'summer');
    });

    test('should handle missing optional fields gracefully', () {
      // Arrange
      final incompleteJson = {
        'success': true,
        'tripData': {
          'destination': 'Test',
          // Missing countryImage
          'days': [],
          'totalEstimatedCost': '1000',
          'budgetTips': '',
          'travelTips': '',
          'emergencycontact': '',
        },
      };

      // Act
      final result = TripPlanResponse.fromJson(incompleteJson);

      // Assert
      expect(result.success, true);
      expect(result.response.destination, 'Test');
      expect(result.response.countryImage, isNull);
      expect(result.response.days.isEmpty, true);
    });

    test('should parse all transportation details correctly', () {
      // Arrange
      final Map<String, dynamic> jsonResponse = jsonDecode(sampleApiResponse);

      // Act
      final result = TripPlanResponse.fromJson(jsonResponse);

      // Count total transportation entries
      int totalTransport = 0;
      for (var day in result.response.days) {
        for (var activity in day.activities) {
          totalTransport += activity.transportation.length;
        }
      }

      // Assert
      expect(totalTransport, 6); // Each activity has 1 transportation entry
    });
  });
}
