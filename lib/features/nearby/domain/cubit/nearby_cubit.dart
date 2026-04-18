import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rahhala_app/features/nearby/domain/cubit/nearby_state.dart';
import 'package:rahhala_app/features/nearby/domain/repositories/nearby_repository.dart';

class NearbyCubit extends Cubit<NearbyState> {
  final NearbyRepository repository;
  NearbyCubit({required this.repository}) : super(NearbyInitial());

  Future<void> requestLocationAndLoad() async {
    emit(NearbyLocationLoading());
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(NearbyError(message: 'Location services are disabled.'));
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          emit(NearbyLocationDenied());
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        emit(NearbyLocationPermanentlyDenied());
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );

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
