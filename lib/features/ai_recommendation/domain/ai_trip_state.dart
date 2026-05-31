import 'package:equatable/equatable.dart';
import 'package:rahhala_app/features/ai_recommendation/data/models/trip_plan_model.dart';
import 'package:rahhala_app/features/ai_recommendation/domain/trip_option.dart';

abstract class AiTripState extends Equatable {
  const AiTripState();
  @override
  List<Object?> get props => [];
}

class AiTripData extends AiTripState {
  final String? destination;
  final int totalDays;
  final String? selectedMonth;
  final String? selectedRange;
  final List<String> selectedInterests;
  final TripOptionsConfig tripOptions;

  const AiTripData({
    this.destination,
    this.totalDays = 3,
    this.selectedMonth,
    this.selectedRange,
    this.selectedInterests = const [],
    this.tripOptions = const TripOptionsConfig.empty(),
  });

  AiTripData copyWith({
    String? destination,
    int? totalDays,
    String? selectedMonth,
    String? selectedRange,
    List<String>? selectedInterests,
    TripOptionsConfig? tripOptions,
  }) {
    return AiTripData(
      destination: destination ?? this.destination,
      totalDays: totalDays ?? this.totalDays,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedRange: selectedRange ?? this.selectedRange,
      selectedInterests: selectedInterests ?? this.selectedInterests,
      tripOptions: tripOptions ?? this.tripOptions,
    );
  }

  @override
  List<Object?> get props => [
        destination,
        totalDays,
        selectedMonth,
        selectedRange,
        selectedInterests,
        tripOptions,
      ];
}

class AiTripInitial extends AiTripData {
  const AiTripInitial()
      : super(
          destination: null,
          totalDays: 3,
          selectedMonth: null,
          selectedRange: null,
          selectedInterests: const [],
          tripOptions: const TripOptionsConfig.empty(),
        );
}

class AiTripLoading extends AiTripData {
  AiTripLoading(AiTripData oldState)
      : super(
          destination: oldState.destination,
          totalDays: oldState.totalDays,
          selectedMonth: oldState.selectedMonth,
          selectedRange: oldState.selectedRange,
          selectedInterests: oldState.selectedInterests,
          tripOptions: oldState.tripOptions,
        );
}

class AiTripSuccess extends AiTripData {
  final TripPlanResponse response;
  final Map<String, dynamic> geminiRequest;

  AiTripSuccess(AiTripData oldState,
      {required this.response, required this.geminiRequest})
      : super(
          destination: oldState.destination,
          totalDays: oldState.totalDays,
          selectedMonth: oldState.selectedMonth,
          selectedRange: oldState.selectedRange,
          selectedInterests: oldState.selectedInterests,
          tripOptions: oldState.tripOptions,
        );

  @override
  List<Object?> get props => [...super.props, response, geminiRequest];
}

class AiTripFailure extends AiTripData {
  final String message;

  AiTripFailure(AiTripData oldState, {required this.message})
      : super(
          destination: oldState.destination,
          totalDays: oldState.totalDays,
          selectedMonth: oldState.selectedMonth,
          selectedRange: oldState.selectedRange,
          selectedInterests: oldState.selectedInterests,
          tripOptions: oldState.tripOptions,
        );

  @override
  List<Object?> get props => [...super.props, message];
}
