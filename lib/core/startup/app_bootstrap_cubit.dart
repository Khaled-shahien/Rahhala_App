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
  AppBootstrapCubit({required AppBootstrapService service})
      : _service = service,
        super(const AppBootstrapInitial());

  final AppBootstrapService _service;

  Future<void> initialize() async {
    emit(const AppBootstrapLoading());
    await Future.delayed(const Duration(seconds: 3));

    try {
      final result = await _service.initialize();
      emit(AppBootstrapReady(result));
    } catch (e, stackTrace) {
      AppErrorReporter.record(
        'AppBootstrapCubit: startup initialization failed',
        error: e,
        stackTrace: stackTrace,
      );
      emit(const AppBootstrapError('Startup failed'));
    }
  }
}
