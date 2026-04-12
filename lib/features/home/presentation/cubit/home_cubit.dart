import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/home_model.dart';
import '../../domain/repositories/home_repository.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeSuccess extends HomeState {
  final List<PlaceModel> places;
  final bool hasMore;
  final bool isLoadingMore;

  HomeSuccess({
    required this.places,
    this.hasMore = true,
    this.isLoadingMore = false,
  });
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository repository;

  List<PlaceModel> _places = [];
  int _currentPage = 1;
  final int _pageSize = 8;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  HomeCubit(this.repository) : super(HomeInitial());

  Future<void> getHomeData() async {
    _places = [];
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;

    emit(HomeLoading());
    try {
      final response = await repository.getHomePlaces(
        page: _currentPage,
        pageSize: _pageSize,
      );
      _places = response.places;
      _hasMore = response.places.length >= _pageSize;

      emit(HomeSuccess(places: List.from(_places), hasMore: _hasMore));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    if (state is! HomeSuccess) return;

    _isLoadingMore = true;
    emit(HomeSuccess(
      places: List.from(_places),
      hasMore: _hasMore,
      isLoadingMore: true,
    ));

    await Future.delayed(const Duration(milliseconds: 1000));

    try {
      _currentPage++;
      final response = await repository.getHomePlaces(
        page: _currentPage,
        pageSize: _pageSize,
      );

      if (response.places.isEmpty) {
        _hasMore = false;
      } else {
        _places.addAll(response.places);
        _hasMore = response.places.length >= _pageSize;
      }

      _isLoadingMore = false;
      emit(HomeSuccess(places: List.from(_places), hasMore: _hasMore));
    } catch (e) {
      _currentPage--;
      _isLoadingMore = false;
      emit(HomeSuccess(
        places: List.from(_places),
        hasMore: _hasMore,
      ));
    }
  }

  Future<void> toggleFavourite(
      String placeId, bool isCurrentlyFavourite) async {
    _places = _places
        .map((place) => place.id == placeId
            ? place.copyWith(isFavourite: !isCurrentlyFavourite)
            : place)
        .toList();

    emit(HomeSuccess(places: List.from(_places), hasMore: _hasMore));

    try {
      if (isCurrentlyFavourite) {
        await repository.removeFavourite(placeId);
      } else {
        await repository.addFavourite(placeId);
      }
    } catch (_) {
      // rollback
      _places = _places
          .map((place) => place.id == placeId
              ? place.copyWith(isFavourite: isCurrentlyFavourite)
              : place)
          .toList();
      emit(HomeSuccess(places: List.from(_places), hasMore: _hasMore));
    }
  }
}
