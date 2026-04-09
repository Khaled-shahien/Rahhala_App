import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rahhala_app/features/home/domain/repositories/home_repository.dart';
import 'place_details_state.dart';

class PlaceDetailsCubit extends Cubit<PlaceDetailsState> {
  final HomeRepository repository;
  PlaceDetailsCubit(this.repository) : super(PlaceDetailsInitial());

  Future<void> getPlaceDetails(String id) async {
    emit(PlaceDetailsLoading());
    try {
      final result = await repository.getPlaceDetails(id);
      emit(PlaceDetailsSuccess(result));
    } catch (e) {
      emit(
          PlaceDetailsError("Failed to load place details. Please try again."));
    }
  }
}
