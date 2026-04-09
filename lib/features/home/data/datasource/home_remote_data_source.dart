import 'package:dio/dio.dart'; // ← 1. لازم تضيفي ده عشان كلمة Options
import 'package:rahhala_app/core/network/end_points.dart';
import 'package:rahhala_app/core/utils/token_storage.dart';
import 'package:rahhala_app/features/home/data/models/home_model.dart';
import '../../../../core/network/api_consumer.dart';
// ← 2. تأكدي من مسار الـ token_storage

abstract class HomeRemoteDataSource {
  Future<List<PlaceModel>> getHomePlaces();
  Future<PlaceDetailsModel> getPlaceDetails(String id);
  Future<void> addReview(String placeId, ReviewRequest reviewRequest);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final ApiConsumer api;
  final TokenStorage tokenStorage; // ← 3. ضفنا التعريف هنا

  // 4. حدثنا الـ Constructor عشان يستلم الـ tokenStorage
  HomeRemoteDataSourceImpl({required this.api, required this.tokenStorage});

  @override
  Future<List<PlaceModel>> getHomePlaces() async {
    final response = await api.get('/api/Home/GetHome');
    return HomeResponse.fromJson(response).places;
  }

  @override
  Future<PlaceDetailsModel> getPlaceDetails(String id) async {
    final response = await api.get(EndPoints.placeDetails(id));
    return PlaceDetailsResponse.fromJson(response).place;
  }

  @override
  Future<void> addReview(String placeId, ReviewRequest reviewRequest) async {
    await api.post(
      'https://rahhallaweb2026.runasp.net/api/Home/Reviews/$placeId',
      data: reviewRequest.toJson(),
    );
  }
}
