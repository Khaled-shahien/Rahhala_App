import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rahhala_app/features/trip_history/domain/cubits/trip_history_state.dart';
import 'package:rahhala_app/features/trip_history/domain/trip_history_repository.dart';

class TripHistoryCubit extends Cubit<TripHistoryState> {
  final TripHistoryRepository repository;

  TripHistoryCubit({required this.repository}) : super(TripHistoryInitial());

  Future<void> loadTrips() async {
    emit(TripHistoryLoading());
    final result = await repository.getMyTrips();
    result.fold(
      (failure) => emit(TripHistoryFailure(failure.message)),
      (response) => emit(TripHistoryLoaded(response)),
    );
  }

  Future<void> loadTripDetail(String tripId) async {
    emit(TripHistoryDetailLoading());
    final result = await repository.getTripById(tripId);
    result.fold(
      (failure) => emit(TripHistoryDetailFailure(failure.message)),
      (response) => emit(TripHistoryDetailLoaded(response)),
    );
  }
}
