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
  BudgetCubit({
    required this.budgetRanges,
  }) : super(BudgetState());

  final List<String> budgetRanges;

  void selectRange(String range) {
    final newSelection = state.selectedRange == range ? null : range;
    emit(state.copyWith(selectedRange: newSelection));
  }
}
