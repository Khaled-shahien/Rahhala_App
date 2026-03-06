# Custom Trip API Integration Documentation

## Overview
This document describes the complete integration of the travel planning API into the Rahhala Flutter application using Clean Architecture principles.

## API Endpoint
**POST** `https://rahhallaweb2026.runasp.net/api/gemini/Generate_Specific_Plan`

### Headers
- `Content-Type: application/json`
- `Authorization: Bearer {JWT_TOKEN}`

### Request Body
```json
{
  "region": "red sea",
  "numberOfDays": 2
}
```

### Response Structure
```json
{
  "success": true,
  "tripData": {
    "destination": "red sea",
    "days": [...],
    "totalEstimatedCost": "4300.00 EGP",
    "travelTips": "Stay hydrated...",
    "tripId": "00000000-0000-0000-0000-000000000000"
  }
}
```

## Architecture Implementation

### 1. Folder Structure
```
lib/features/custom_trip/
├── data/
│   ├── models/
│   │   ├── transportation_model.dart
│   │   ├── activity_model.dart
│   │   ├── day_plan_model.dart
│   │   └── trip_data_model.dart
│   ├── repositories/
│   │   └── trip_repository.dart
│   └── sources/
│       └── trip_api_service.dart
├── domain/
│   ├── entities/
│   │   ├── transportation_entity.dart
│   │   ├── activity_entity.dart
│   │   ├── day_plan_entity.dart
│   │   └── trip_data_entity.dart
│   ├── repositories/
│   │   └── trip_repository_interface.dart
│   └── usecases/
│       └── generate_trip_plan_usecase.dart
└── presentation/
    ├── cubit/
    │   ├── custom_trip_cubit.dart
    │   └── custom_trip_state.dart
    ├── widgets/
    │   ├── custom_trip_input_step.dart
    │   └── trip_display_screen.dart
    └── pages/
        ├── custom_trip_flow_screen.dart
        └── custom_trip_splash_screen.dart
```

### 2. Data Layer

#### Models
All models follow the same pattern with `fromJson` and `toJson` methods:
- **TransportationModel**: Represents transportation between locations
- **ActivityModel**: Represents an activity with place, time, cost, and transportation
- **DayPlanModel**: Represents a single day plan with multiple activities
- **TripDataModel**: Complete trip response from API

#### API Service (`TripApiService`)
- Handles HTTP requests using Dio
- Implements proper error handling for network issues
- Parses API responses and handles different status codes

#### Repository (`TripRepository`)
- Implements retry logic with exponential backoff (1s, 2s, 4s) for HTTP 503 errors
- Converts models to entities
- Returns Either type for error handling (using dartz package)

### 3. Domain Layer

#### Entities
Pure Dart classes representing business objects:
- **TransportationEntity**
- **ActivityEntity**
- **DayPlanEntity**
- **TripDataEntity**

#### Repository Interface
```dart
abstract class TripRepositoryInterface {
  Future<Either<String, TripDataEntity>> generateTripPlan({
    required String region,
    required int numberOfDays,
  });
}
```

#### Use Case
```dart
class GenerateTripPlanUsecase {
  final TripRepositoryInterface repository;
  
  Future<Either<String, TripDataEntity>> call({
    required String region,
    required int numberOfDays,
  }) async {
    return await repository.generateTripPlan(
      region: region,
      numberOfDays: numberOfDays,
    );
  }
}
```

### 4. Presentation Layer

#### Cubit (`CustomTripCubit`)
Manages state for trip generation:
- **States**: `initial`, `loading`, `success`, `error`
- **Methods**:
  - `updateRegion(String)`: Update selected region
  - `updateDays(int)`: Update number of days
  - `generateTripPlan()`: Call API to generate trip
  - `reset()`: Reset to initial state

#### State (`CustomTripState`)
```dart
enum CustomTripStatus { initial, loading, success, error }

class CustomTripState extends Equatable {
  final CustomTripStatus status;
  final String? selectedRegion;
  final int numberOfDays;
  final TripDataEntity? tripData;
  final String? errorMessage;
}
```

#### UI Components
1. **CustomTripInputStep**: User input for region and days selection
2. **CustomTripSplashScreen**: Loading animation while generating trip
3. **TripDisplayScreen**: Displays the generated trip itinerary

## Key Features

### 1. Retry Logic
The implementation includes intelligent retry logic specifically for handling HTTP 503 errors from the Gemini service:
- Maximum 3 retry attempts
- Exponential backoff: 1s, 2s, 4s delays
- Only retries on 503 errors, other errors fail immediately

### 2. Error Handling
Comprehensive error handling throughout the stack:
- Network errors (timeout, connection lost)
- Server errors (503, 500, etc.)
- Invalid response format
- Null safety checks

### 3. State Management
Using flutter_bloc for predictable state management:
- Clear separation of concerns
- Easy to test and maintain
- Follows existing project patterns

### 4. Dependency Injection
All dependencies registered in `service_locator.dart`:
```dart
sl.registerLazySingleton<TripApiService>(() => TripApiService(dio: sl<Dio>()));
sl.registerLazySingleton<TripRepositoryInterface>(
    () => TripRepository(apiService: sl<TripApiService>()));
sl.registerLazySingleton<GenerateTripPlanUsecase>(
    () => GenerateTripPlanUsecase(sl<TripRepositoryInterface>()));
sl.registerFactory<CustomTripCubit>(
    () => CustomTripCubit(generateTripPlanUsecase: sl<GenerateTripPlanUsecase>()));
```

## Usage Example

### Basic Usage
```dart
// In your screen
BlocProvider(
  create: (_) => sl<CustomTripCubit>(),
  child: CustomTripInputStep(
    onNext: () {
      final cubit = context.read<CustomTripCubit>();
      cubit.generateTripPlan();
    },
  ),
)
```

### Listening to State Changes
```dart
BlocBuilder<CustomTripCubit, CustomTripState>(
  builder: (context, state) {
    switch (state.status) {
      case CustomTripStatus.loading:
        return CircularProgressIndicator();
      case CustomTripStatus.success:
        return TripDisplayScreen(tripData: state.tripData!);
      case CustomTripStatus.error:
        return ErrorWidget(state.errorMessage);
      default:
        return InputForm();
    }
  },
)
```

## Testing Considerations

### Unit Tests
Test the following:
1. **UseCase**: Verify it calls repository with correct parameters
2. **Repository**: Test retry logic and model-to-entity mapping
3. **Cubit**: Test state transitions and error handling

### Integration Tests
1. API endpoint connectivity
2. Full flow from input to trip display
3. Error scenarios (no internet, server errors)

## Production Readiness

### ✅ Implemented
- [x] Clean architecture layers
- [x] Null safety
- [x] Error handling
- [x] Retry logic for flaky API
- [x] State management
- [x] Dependency injection
- [x] JSON parsing
- [x] Loading states
- [x] User feedback

### 🔧 Recommended Enhancements
1. Add caching for generated trips
2. Implement offline mode with local storage
3. Add analytics tracking
4. Add pull-to-refresh for regenerating trips
5. Add ability to save favorite trips
6. Implement pagination for long trips

## Troubleshooting

### Common Issues

**Issue**: API returns 503 repeatedly
**Solution**: Retry logic automatically handles this with exponential backoff

**Issue**: No internet connection
**Solution**: Error message displayed to user, can retry when connection restored

**Issue**: Invalid region selected
**Solution**: Validation before API call, button disabled until valid region selected

**Issue**: Long loading times
**Solution**: Loading animation with messages keeps user engaged

## API Configuration

The base URL is configured in `lib/core/network/end_points.dart`:
```dart
static const String baseUrl = 'https://rahhallaweb2026.runasp.net';
static const String generateSpecificPlan = '/api/gemini/Generate_Specific_Plan';
```

Authentication tokens are automatically added by `ApiInterceptors` for authenticated requests.

## Support

For issues or questions:
- Check the code comments for inline documentation
- Review the implementation files in the specified folder structure
- Refer to the existing project patterns for consistency

---

**Last Updated**: March 6, 2026
**Version**: 1.0.0
