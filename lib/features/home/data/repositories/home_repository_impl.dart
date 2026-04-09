import '../../domain/repositories/home_repository.dart';
import '../datasource/home_remote_data_source.dart';
import '../models/home_model.dart';

// 1. لازم نخليه implements HomeRepository عشان الـ Cubit يشوف الفانكشنز
class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<PlaceModel>> getHomePlaces() async {
    try {
      return await remoteDataSource.getHomePlaces();
    } catch (e) {
      rethrow;
    }
  }

  // 2. ضيفي الفانكشن دي هنا عشان الإيرور اللي في الـ Cubit يروح
  @override
  Future<PlaceDetailsModel> getPlaceDetails(String id) async {
    try {
      return await remoteDataSource.getPlaceDetails(id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> addReview(String placeId, ReviewRequest reviewRequest) async {
    return await remoteDataSource.addReview(placeId, reviewRequest);
  }
}
