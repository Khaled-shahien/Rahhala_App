import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rahhala_app/core/crash/app_error_reporter.dart';
import 'package:rahhala_app/core/startup/app_bootstrap_service.dart';

abstract class AppBootstrapState extends Equatable {
  const AppBootstrapState();

  @override
  List<Object?> get props => [];
}

class AppBootstrapInitial extends AppBootstrapState {
  const AppBootstrapInitial();
}

class AppBootstrapLoading extends AppBootstrapState {
  const AppBootstrapLoading();
}

class AppBootstrapReady extends AppBootstrapState {
  const AppBootstrapReady(this.result);

  final BootstrapResult result;

  @override
  List<Object?> get props => [result];
}

class AppBootstrapError extends AppBootstrapState {
  const AppBootstrapError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class AppBootstrapCubit extends Cubit<AppBootstrapState> {
  AppBootstrapCubit({
    required AppBootstrapService service,
    this.minimumSplashDuration = const Duration(milliseconds: 1200),
  })  : _service = service,
        super(const AppBootstrapInitial());

  final AppBootstrapService _service;

  /// Shortest time the splash stays visible, so it doesn't just flash.
  /// It runs at the same time as initialization rather than adding to it.
  final Duration minimumSplashDuration;

  Future<void> initialize() async {
    emit(const AppBootstrapLoading());

    final minimumDisplay = Future<void>.delayed(minimumSplashDuration);
    try {
      final result = await _service.initialize();
      await minimumDisplay;
      if (isClosed) return;
      emit(AppBootstrapReady(result));
    } catch (e, stackTrace) {
      AppErrorReporter.record(
        'AppBootstrapCubit: startup initialization failed',
        error: e,
        stackTrace: stackTrace,
      );
      await minimumDisplay;
      if (isClosed) return;
      emit(const AppBootstrapError('Startup failed'));
    }
  }
}
