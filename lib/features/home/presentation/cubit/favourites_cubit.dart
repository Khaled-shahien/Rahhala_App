import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rahhala_app/core/errors/exceptions.dart';
import 'package:rahhala_app/core/errors/failures.dart';
import 'package:rahhala_app/core/localization/app_messages.dart';
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

  /// True when the user must sign in to see favourites (guest or expired
  /// session), so the UI can offer a login action instead of "retry".
  final bool requiresLogin;

  FavouritesError(this.message, {this.requiresLogin = false});
}

class FavouritesCubit extends Cubit<FavouritesState> {
  final HomeRepository repository;
  List<FavouriteModel> _cache = <FavouriteModel>[];

  FavouritesCubit(this.repository) : super(FavouritesInitial());

  Future<void> getFavourites() async {
    emit(FavouritesLoading());
    try {
      final data = await repository.getFavourites();
      if (isClosed) return;
      _cache = data;
      emit(FavouritesSuccess(List<FavouriteModel>.from(_cache)));
    } catch (e) {
      AppLogger.instance
          .w('FavouritesCubit: Failed to load favourites', error: e);
      if (isClosed) return;
      final failure = failureFromError(e);
      if (failure.type == FailureType.unauthorized) {
        emit(FavouritesError(
          AppMessages.current.favouritesLoginRequired,
          requiresLogin: true,
        ));
      } else {
        emit(FavouritesError(failure.message));
      }
    }
  }

  Future<void> removeFavourite(String placeId) async {
    final previous = List<FavouriteModel>.from(_cache);
    _cache = _cache.where((item) => item.id != placeId).toList();
    emit(FavouritesSuccess(List<FavouriteModel>.from(_cache)));

    try {
      await repository.removeFavourite(placeId);
      if (isClosed) return;
      emit(FavouritesSuccess(
        List<FavouriteModel>.from(_cache),
        message: AppMessages.current.favouritesRemoved,
      ));
    } catch (e) {
      AppLogger.instance
          .w('FavouritesCubit: Failed to remove favourite', error: e);
      if (isClosed) return;
      _cache = previous;
      emit(FavouritesSuccess(
        List<FavouriteModel>.from(_cache),
        message: AppMessages.current.favouritesRemoveFailed,
      ));
    }
  }
}
