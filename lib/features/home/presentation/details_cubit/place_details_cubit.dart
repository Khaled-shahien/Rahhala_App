import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rahhala_app/core/errors/exceptions.dart';
import 'package:rahhala_app/core/localization/app_messages.dart';
import 'package:rahhala_app/features/home/domain/repositories/home_repository.dart';
import 'place_details_state.dart';

class PlaceDetailsCubit extends Cubit<PlaceDetailsState> {
  final HomeRepository repository;
  PlaceDetailsCubit(this.repository) : super(PlaceDetailsInitial());

  Future<void> getPlaceDetails(String id) async {
    emit(PlaceDetailsLoading());
    try {
      final result = await repository.getPlaceDetails(id);
      if (isClosed) return;
      emit(PlaceDetailsSuccess(result));
    } catch (e) {
      if (isClosed) return;
      final failure = failureFromError(e);
      emit(PlaceDetailsError(
        failure.isConnectivity
            ? failure.message
            : AppMessages.current.errorPlaceDetailsLoadFailed,
      ));
    }
  }
}
