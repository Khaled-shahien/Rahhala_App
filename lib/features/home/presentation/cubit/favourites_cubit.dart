import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rahhala_app/core/logging/app_logger.dart';
import 'package:rahhala_app/features/home/data/models/home_model.dart';
import 'package:rahhala_app/features/home/domain/repositories/home_repository.dart';

abstract class FavouritesState {}

class FavouritesInitial extends FavouritesState {}

class FavouritesLoading extends FavouritesState {}

class FavouritesSuccess extends FavouritesState {
  final List<FavouriteModel> favourites;
  final String? message;

  FavouritesSuccess(this.favourites, {this.message});
}

class FavouritesError extends FavouritesState {
  final String message;
  FavouritesError(this.message);
}

class FavouritesCubit extends Cubit<FavouritesState> {
  final HomeRepository repository;
  List<FavouriteModel> _cache = <FavouriteModel>[];

  FavouritesCubit(this.repository) : super(FavouritesInitial());

  Future<void> getFavourites() async {
    emit(FavouritesLoading());
    try {
      final data = await repository.getFavourites();
      _cache = data;
      emit(FavouritesSuccess(List<FavouriteModel>.from(_cache)));
    } catch (e) {
      AppLogger.instance.w('FavouritesCubit: Failed to load favourites', error: e);
      emit(FavouritesError('Please log in to view your favourites.'));
    }
  }

  Future<void> removeFavourite(String placeId) async {
    final previous = List<FavouriteModel>.from(_cache);
    _cache = _cache.where((item) => item.id != placeId).toList();
    emit(FavouritesSuccess(List<FavouriteModel>.from(_cache)));

    try {
      await repository.removeFavourite(placeId);
      emit(FavouritesSuccess(
        List<FavouriteModel>.from(_cache),
        message: 'Removed from favourites.',
      ));
    } catch (e) {
      AppLogger.instance.w('FavouritesCubit: Failed to remove favourite', error: e);
      _cache = previous;
      emit(FavouritesSuccess(
        List<FavouriteModel>.from(_cache),
        message: 'Unable to remove this place now. Please try again.',
      ));
    }
  }
}
