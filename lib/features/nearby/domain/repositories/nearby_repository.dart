import 'package:rahhala_app/features/nearby/domain/entities/nearby_entities.dart';

abstract class NearbyRepository {
  Future<NearbyResponseModel> getNearbyPlaces({
    required double latitude,
    required double longitude,
  });
}
