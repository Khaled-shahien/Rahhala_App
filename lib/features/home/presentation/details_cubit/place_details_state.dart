import '../../data/models/home_model.dart';

abstract class PlaceDetailsState {}

class PlaceDetailsInitial extends PlaceDetailsState {}

class PlaceDetailsLoading extends PlaceDetailsState {}

class PlaceDetailsSuccess extends PlaceDetailsState {
  final PlaceDetailsModel placeDetails;
  PlaceDetailsSuccess(this.placeDetails);
}

class PlaceDetailsError extends PlaceDetailsState {
  final String message;
  PlaceDetailsError(this.message);
}
