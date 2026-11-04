import 'package:rahhala_app/features/ai_recommendation/domain/trip_option.dart';

abstract class TripOptionsRepository {
  Future<TripOptionsConfig> getTripOptions();
}
