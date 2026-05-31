import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rahhala_app/features/nearby/domain/cubit/nearby_state.dart';
import 'package:rahhala_app/features/nearby/domain/repositories/nearby_repository.dart';
import 'package:rahhala_app/features/nearby/domain/services/location_service.dart';

class NearbyCubit extends Cubit<NearbyState> {
  final NearbyRepository repository;
  final LocationService locationService;

  NearbyCubit({
    required this.repository,
    required this.locationService,
  }) : super(NearbyInitial());

  Future<void> requestLocationAndLoad() async {
    emit(NearbyLocationLoading());
    try {
      final position = await locationService.getCurrentLocation();

      emit(NearbyPlacesLoading(
        latitude: position.latitude,
        longitude: position.longitude,
      ));

      final response = await repository.getNearbyPlaces(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      emit(NearbyPlacesLoaded(
        response: response,
        latitude: position.latitude,
        longitude: position.longitude,
      ));
    } on LocationServiceException catch (e) {
      switch (e.reason) {
        case LocationFailureReason.permissionDenied:
          emit(NearbyLocationDenied());
          break;
        case LocationFailureReason.permissionDeniedForever:
          emit(NearbyLocationPermanentlyDenied());
          break;
        case LocationFailureReason.serviceDisabled:
        case LocationFailureReason.unavailable:
          emit(NearbyError(message: e.message));
          break;
      }
    } catch (e) {
      emit(NearbyError(message: e.toString()));
    }
  }

  void filterByCategory(String category) {
    final current = state;
    if (current is NearbyPlacesLoaded) {
      emit(current.copyWith(selectedCategory: category));
    }
  }
}
