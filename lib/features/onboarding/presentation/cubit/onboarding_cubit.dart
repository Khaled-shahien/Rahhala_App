import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rahhala_app/core/crash/app_error_reporter.dart';
import 'package:rahhala_app/features/onboarding/domain/repositories/onboarding_repository.dart';

class OnboardingState extends Equatable {
  const OnboardingState({
    this.currentPage = 0,
    this.isCompleting = false,
    this.isCompleted = false,
    this.errorMessage,
  });

  final int currentPage;
  final bool isCompleting;
  final bool isCompleted;
  final String? errorMessage;

  OnboardingState copyWith({
    int? currentPage,
    bool? isCompleting,
    bool? isCompleted,
    String? errorMessage,
  }) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      isCompleting: isCompleting ?? this.isCompleting,
      isCompleted: isCompleted ?? this.isCompleted,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        currentPage,
        isCompleting,
        isCompleted,
        errorMessage,
      ];
}

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit({required OnboardingRepository repository})
      : _repository = repository,
        super(const OnboardingState());

  final OnboardingRepository _repository;

  void pageChanged(int page) {
    emit(state.copyWith(currentPage: page, errorMessage: null));
  }

  Future<void> completeOnboarding() async {
    emit(state.copyWith(isCompleting: true, errorMessage: null));

    try {
      await _repository.markOnboardingCompleted();
      emit(state.copyWith(isCompleting: false, isCompleted: true));
    } catch (e, stackTrace) {
      AppErrorReporter.record(
        'OnboardingCubit: failed to complete onboarding',
        error: e,
        stackTrace: stackTrace,
      );
      emit(state.copyWith(
        isCompleting: false,
        errorMessage: 'Could not finish onboarding. Please try again.',
      ));
    }
  }
}
