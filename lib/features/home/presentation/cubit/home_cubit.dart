import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/home_model.dart';
import '../../domain/repositories/home_repository.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeSuccess extends HomeState {
  final List<PlaceModel> places;
  HomeSuccess(this.places);
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository repository;
  List<PlaceModel> _places = <PlaceModel>[];

  HomeCubit(this.repository) : super(HomeInitial());

  Future<void> getHomeData() async {
    emit(HomeLoading());
    try {
      final places = await repository.getHomePlaces();
      _places = places;
      emit(HomeSuccess(List<PlaceModel>.from(_places)));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> toggleFavourite(
      String placeId, bool isCurrentlyFavourite) async {
    if (_places.isEmpty && state is HomeSuccess) {
      _places = List<PlaceModel>.from((state as HomeSuccess).places);
    }

    _places = _places
        .map(
          (place) => place.id == placeId
              ? place.copyWith(isFavourite: !isCurrentlyFavourite)
              : place,
        )
        .toList();
    emit(HomeSuccess(List<PlaceModel>.from(_places)));

    try {
      if (isCurrentlyFavourite) {
        await repository.removeFavourite(placeId);
      } else {
        await repository.addFavourite(placeId);
      }
    } catch (_) {
      _places = _places
          .map(
            (place) => place.id == placeId
                ? place.copyWith(isFavourite: isCurrentlyFavourite)
                : place,
          )
          .toList();
      emit(HomeSuccess(List<PlaceModel>.from(_places)));
    }
  }
}
