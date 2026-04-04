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

  Future<void> regenerateTripPlan(
    String tripId,
    String destination,
    int numberOfDays,
    String budget,
    List<String> interests,
    String season,
  ) async {
    emit(TripRegenerateLoading());
    final result = await repository.regenerateTripPlan(
      tripId,
      destination,
      numberOfDays,
      budget,
      interests,
      season,
    );
    result.fold(
      (failure) => emit(TripRegenerateFailure(failure.message)),
      (response) => emit(TripRegenerateSuccess(response)),
    );
  }
}
