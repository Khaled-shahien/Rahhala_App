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
  HomeCubit(this.repository) : super(HomeInitial());

  Future<void> getHomeData() async {
    emit(HomeLoading());
    try {
      final places = await repository.getHomePlaces();
      emit(HomeSuccess(places));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
