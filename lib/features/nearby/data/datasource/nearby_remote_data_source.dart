import 'package:rahhala_app/core/network/api_consumer.dart';
import 'package:rahhala_app/core/network/end_points.dart';
import 'package:rahhala_app/features/nearby/data/models/nearby_response_model.dart';

abstract class NearbyRemoteDataSource {
  Future<NearbyResponseModel> getNearbyPlaces({
    required double latitude,
    required double longitude,
  });
}

class NearbyRemoteDataSourceImpl implements NearbyRemoteDataSource {
  final ApiConsumer api;
  NearbyRemoteDataSourceImpl({required this.api});

  @override
  Future<NearbyResponseModel> getNearbyPlaces({
    required double latitude,
    required double longitude,
  }) async {
    final response = await api.get(
      EndPoints.nearbyPlaces,
      queryParameters: {'lat': latitude, 'lng': longitude},
    );
    return NearbyResponseModel.fromJson(response);
  }
}
