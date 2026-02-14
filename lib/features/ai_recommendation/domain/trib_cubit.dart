import 'package:flutter_bloc/flutter_bloc.dart';

class TripState {
  final String destination;
  final int totalDays;
  final String? selectedMonth;

  TripState({
    this.destination = '',
    this.totalDays = 3,
    this.selectedMonth,
  });

  TripState copyWith({
    String? destination,
    int? totalDays,
    String? selectedMonth,
  }) {
    return TripState(
      destination: destination ?? this.destination,
      totalDays: totalDays ?? this.totalDays,
      selectedMonth: selectedMonth ?? this.selectedMonth,
    );
  }
}

class TripCubit extends Cubit<TripState> {
  TripCubit() : super(TripState());

  void updateDestination(String dest) =>
      emit(state.copyWith(destination: dest));

  void updateDays(int days) => emit(state.copyWith(totalDays: days));

  void selectMonth(String? month) {
    final newSelection = state.selectedMonth == month ? null : month;

    emit(state.copyWith(selectedMonth: newSelection));
  }
}
