

import 'package:flutter_bloc/flutter_bloc.dart';

class BudgetState {
  final String? selectedRange;

  BudgetState({this.selectedRange});

  BudgetState copyWith({
    String? selectedRange,
  }) {
    return BudgetState(
      selectedRange: selectedRange,
    );
  }
}

class BudgetCubit extends Cubit<BudgetState> {
  final List<String> budgetRanges = [
    'Less 5000',
    'From 5000 to 10000',
    'From 10000 to 15000',
    'From 15000 to 20000',
    'More than 20000',
  ];

  BudgetCubit() : super(BudgetState());

  void selectRange(String range) {
    
    final newSelection = state.selectedRange == range ? null : range;
    emit(state.copyWith(selectedRange: newSelection));
  }
}