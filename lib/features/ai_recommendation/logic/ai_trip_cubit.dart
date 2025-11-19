

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rahhala_app/features/ai_recommendation/data/repositories/gemini_repository.dart';
import 'package:rahhala_app/features/ai_recommendation/logic/ai_trip_state.dart';

class AiTripCubit extends Cubit<AiTripState> {
  final GeminiRepository geminiRepository;

  final List<String> budgetRanges = [
    'Less 5000',
    'From 5000 to 10000',
    'From 10000 to 15000',
    'From 15000 to 20000',
    'More than 20000',
  ];
  final List<String> availableInterests = [
    'Nature',
    'Adventure',
    'Relaxation',
    'Historical sites',
    'Morning activity',
    'Night activity',
    'Shopping',
    'Hidden gems'
  ];

  AiTripCubit({required this.geminiRepository}) : super(const AiTripInitial());

  void updateDestination(String dest) {
    if (state is AiTripData) {
      emit((state as AiTripData).copyWith(destination: dest));
    }
  }

  void updateDays(int days) {
    if (state is AiTripData) {
      emit((state as AiTripData).copyWith(totalDays: days));
    }
  }

  void selectMonth(String? month) {
    if (state is AiTripData) {
      emit((state as AiTripData).copyWith(selectedMonth: month));
    }
  }

  void selectRange(String range) {
    if (state is AiTripData) {
      emit((state as AiTripData).copyWith(selectedRange: range));
    }
  }

  void toggleInterest(String interest) {
    if (state is! AiTripData) return;
    final currentData = state as AiTripData;
    final current = List<String>.from(currentData.selectedInterests);
    if (current.contains(interest)) {
      current.remove(interest);
    } else {
      current.add(interest);
    }
    emit(currentData.copyWith(selectedInterests: current));
  }

  String _parseBudget(String? range) {
    if (range == null) return "5000";
    if (range.startsWith('Less')) return "5000";
    if (range.startsWith('More')) return "25000";

    final numbers =
        RegExp(r'\d+').allMatches(range).map((m) => m.group(0)!).toList();
    if (numbers.length == 2) {
      
      return (double.tryParse(numbers[1]) ?? 10000.0).toInt().toString();
    }
    return "10000"; 
  }

  Future<void> generateTripPlan() async {
    if (state is! AiTripData || state is AiTripLoading) return;
    final currentState = state as AiTripData;

    if (currentState.destination == null || currentState.destination!.isEmpty) {
      emit(
          AiTripFailure(currentState, message: "Please select a destination."));
      return;
    }
    if (currentState.selectedMonth == null ||
        currentState.selectedMonth!.isEmpty) {
      emit(AiTripFailure(currentState,
          message: "Please select a travel month."));
      return;
    }
    if (currentState.selectedRange == null) {
      emit(AiTripFailure(currentState,
          message: "Please select a budget range."));
      return;
    }
    if (currentState.selectedInterests.isEmpty) {
      emit(AiTripFailure(currentState,
          message: "Please select at least one interest."));
      return;
    }

    emit(AiTripLoading(currentState));

    final String region = "${currentState.destination!}, Egypt";
    final int numberOfDays = currentState.totalDays;
    final String budget =
        _parseBudget(currentState.selectedRange); 
    final List<String> interestTypes = currentState.selectedInterests;
    final String travelMonth = currentState.selectedMonth!;

    final result = await geminiRepository.getTripPlan(
      region: region,
      numberOfDays: numberOfDays,
      budget: budget, 
      interestTypes: interestTypes,
      travelMonth: travelMonth,
    );

    result.fold(
      (failure) => emit(AiTripFailure(currentState, message: failure.message)),
      (tripPlanResponse) =>
          emit(AiTripSuccess(currentState, response: tripPlanResponse)),
    );
  }
}
