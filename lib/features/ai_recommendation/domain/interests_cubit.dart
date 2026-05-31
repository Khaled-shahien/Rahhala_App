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
  InterestsCubit({
    required this.availableInterests,
  }) : super(InterestsState());

  final List<String> availableInterests;

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
