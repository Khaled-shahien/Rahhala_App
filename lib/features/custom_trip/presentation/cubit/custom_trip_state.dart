// lib/features/custom_trip/presentation/cubit/custom_trip_state.dart

part of 'custom_trip_cubit.dart';

abstract class CustomTripState extends Equatable {
  const CustomTripState();

  String? get selectedRegion => null;
  int get numberOfDays => 1;

  CustomTripState copyWith({String? selectedRegion, int? numberOfDays});

  @override
  List<Object?> get props => [selectedRegion, numberOfDays];
}

class CustomTripInitial extends CustomTripState {
  @override
  final String? selectedRegion;
  @override
  final int numberOfDays;

  const CustomTripInitial({
    this.selectedRegion,
    this.numberOfDays = 1,
  });

  @override
  List<Object?> get props => [selectedRegion, numberOfDays];

  @override
  CustomTripInitial copyWith({
    String? selectedRegion,
    int? numberOfDays,
  }) {
    return CustomTripInitial(
      selectedRegion: selectedRegion ?? this.selectedRegion,
      numberOfDays: numberOfDays ?? this.numberOfDays,
    );
  }
}

class CustomTripLoading extends CustomTripState {
  @override
  final String? selectedRegion;
  @override
  final int numberOfDays;

  const CustomTripLoading({
    this.selectedRegion,
    this.numberOfDays = 1,
  });

  @override
  List<Object?> get props => [selectedRegion, numberOfDays];

  @override
  CustomTripLoading copyWith({
    String? selectedRegion,
    int? numberOfDays,
  }) {
    return CustomTripLoading(
      selectedRegion: selectedRegion ?? this.selectedRegion,
      numberOfDays: numberOfDays ?? this.numberOfDays,
    );
  }
}

class CustomTripSuccess extends CustomTripState {
  @override
  final String? selectedRegion;
  @override
  final int numberOfDays;
  final TripDataEntity tripData;

  const CustomTripSuccess({
    required this.selectedRegion,
    required this.numberOfDays,
    required this.tripData,
  });

  @override
  List<Object?> get props => [selectedRegion, numberOfDays, tripData];

  @override
  CustomTripSuccess copyWith({
    String? selectedRegion,
    int? numberOfDays,
    TripDataEntity? tripData,
  }) {
    return CustomTripSuccess(
      selectedRegion: selectedRegion ?? this.selectedRegion,
      numberOfDays: numberOfDays ?? this.numberOfDays,
      tripData: tripData ?? this.tripData,
    );
  }
}

class CustomTripFailure extends CustomTripState {
  final String message;
  @override
  final String? selectedRegion;
  @override
  final int numberOfDays;

  const CustomTripFailure({
    required this.message,
    this.selectedRegion,
    this.numberOfDays = 1,
  });

  @override
  List<Object?> get props => [message, selectedRegion, numberOfDays];

  @override
  CustomTripFailure copyWith({
    String? message,
    String? selectedRegion,
    int? numberOfDays,
  }) {
    return CustomTripFailure(
      message: message ?? this.message,
      selectedRegion: selectedRegion ?? this.selectedRegion,
      numberOfDays: numberOfDays ?? this.numberOfDays,
    );
  }
}
