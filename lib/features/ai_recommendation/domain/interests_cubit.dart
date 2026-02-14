

import 'package:flutter_bloc/flutter_bloc.dart';

class InterestsState {
  final List<String> selectedInterests;

  InterestsState({this.selectedInterests = const []});

  InterestsState copyWith({
    List<String>? selectedInterests,
  }) {
    return InterestsState(
      selectedInterests: selectedInterests ?? this.selectedInterests,
    );
  }
}

class InterestsCubit extends Cubit<InterestsState> {

  final List<String> availableInterests = [
    'Nature', 'Adventure', 'Relaxation', 'Historical sites',
    'Morning activity', 'Night activity', 'Shopping', 'Hidden gems'
  ];

  InterestsCubit() : super(InterestsState());

  void toggleInterest(String interest) {
    final current = List<String>.from(state.selectedInterests);
    if (current.contains(interest)) {
      current.remove(interest);
    } else {
      current.add(interest);
    }
    emit(state.copyWith(selectedInterests: current));
  }
}