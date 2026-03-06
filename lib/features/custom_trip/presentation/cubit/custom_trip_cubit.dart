// lib/features/custom_trip/presentation/cubit/custom_trip_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/trip_data_entity.dart';
import '../../domain/usecases/generate_trip_plan_usecase.dart';

part 'custom_trip_state.dart';

class CustomTripCubit extends Cubit<CustomTripState> {
  final GenerateTripPlanUsecase generateTripPlanUsecase;

  CustomTripCubit({required this.generateTripPlanUsecase})
      : super(const CustomTripInitial());

  String? _selectedRegion;
  int _numberOfDays = 1;

  String? get selectedRegion => _selectedRegion;
  int get numberOfDays => _numberOfDays;

  void updateRegion(String? region) {
    _selectedRegion = region;
    emit(state.copyWith(selectedRegion: region));
  }

  void updateDays(int days) {
    if (days >= 1 && days <= 30) {
      _numberOfDays = days;
      emit(state.copyWith(numberOfDays: days));
    }
  }

  Future<void> generateTripPlan() async {
    if (_selectedRegion == null || _selectedRegion!.isEmpty) {
      emit(CustomTripFailure(
        message: 'Please select a region',
        selectedRegion: _selectedRegion,
        numberOfDays: _numberOfDays,
      ));
      return;
    }

    emit(CustomTripLoading(
      selectedRegion: _selectedRegion,
      numberOfDays: _numberOfDays,
    ));

    try {
      final result = await generateTripPlanUsecase.call(
        region: _selectedRegion!,
        numberOfDays: _numberOfDays,
      );

      result.fold(
        (errorMessage) {
          emit(CustomTripFailure(
            message: errorMessage,
            selectedRegion: _selectedRegion,
            numberOfDays: _numberOfDays,
          ));
        },
        (tripData) {
          emit(CustomTripSuccess(
            selectedRegion: _selectedRegion,
            numberOfDays: _numberOfDays,
            tripData: tripData,
          ));
        },
      );
    } catch (e) {
      emit(CustomTripFailure(
        message: e.toString(),
        selectedRegion: _selectedRegion,
        numberOfDays: _numberOfDays,
      ));
    }
  }

  void reset() {
    _selectedRegion = null;
    _numberOfDays = 1;
    emit(const CustomTripInitial());
  }
}
