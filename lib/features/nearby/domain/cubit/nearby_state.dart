import 'package:rahhala_app/features/nearby/domain/entities/nearby_place.dart';
import 'package:rahhala_app/features/nearby/domain/entities/nearby_entities.dart';

abstract class NearbyState {}

class NearbyInitial extends NearbyState {}

class NearbyLocationLoading extends NearbyState {}

class NearbyPlacesLoading extends NearbyState {
  final double latitude;
  final double longitude;
  NearbyPlacesLoading({required this.latitude, required this.longitude});
}

class NearbyPlacesLoaded extends NearbyState {
  final NearbyResponseModel response;
  final double latitude;
  final double longitude;
  final String selectedCategory;

  NearbyPlacesLoaded({
    required this.response,
    required this.latitude,
    required this.longitude,
    this.selectedCategory = 'All',
  });

  List<NearbyPlaceModel> get filteredPlaces {
    if (selectedCategory == 'All') return response.results;
    return response.sections[selectedCategory] ?? [];
  }

  NearbyPlacesLoaded copyWith({String? selectedCategory}) {
    return NearbyPlacesLoaded(
      response: response,
      latitude: latitude,
      longitude: longitude,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

class NearbyLocationDenied extends NearbyState {}

class NearbyLocationPermanentlyDenied extends NearbyState {}

class NearbyError extends NearbyState {
  final String message;
  NearbyError({required this.message});
}
