import 'package:rahhala_app/features/nearby/data/datasource/nearby_remote_data_source.dart';
import 'package:rahhala_app/features/nearby/data/models/nearby_response_model.dart';
import 'package:rahhala_app/features/nearby/domain/repositories/nearby_repository.dart';

class NearbyRepositoryImpl implements NearbyRepository {
  final NearbyRemoteDataSource remoteDataSource;
  NearbyRepositoryImpl({required this.remoteDataSource});

  @override
  Future<NearbyResponseModel> getNearbyPlaces({
    required double latitude,
    required double longitude,
  }) async {
    return await remoteDataSource.getNearbyPlaces(
      latitude: latitude,
      longitude: longitude,
    );
  }
}
