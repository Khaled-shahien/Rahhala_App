import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rahhala_app/core/constants/app_colors.dart';
import 'package:rahhala_app/core/di/service_locator.dart';
import 'package:rahhala_app/features/ai_recommendation/domain/ai_trip_cubit.dart';
import 'package:rahhala_app/features/ai_recommendation/domain/ai_trip_state.dart';
import 'package:rahhala_app/features/custom_trip/presentation/pages/custom_trip_splash_screen.dart';
import 'package:rahhala_app/features/custom_trip/presentation/widgets/custom_trip_input_step.dart';

class CustomTripFlowScreen extends StatefulWidget {
  const CustomTripFlowScreen({super.key});

  @override
  State<CustomTripFlowScreen> createState() => _CustomTripFlowScreenState();
}

class _CustomTripFlowScreenState extends State<CustomTripFlowScreen> {
  int _currentStep = 0;
  String _destination = '';
  int _days = 3;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AiTripCubit(geminiRepository: sl())..init(),
      child: Builder(
        builder: (innerContext) {
          void goToSplash() {
            final cubit = innerContext.read<AiTripCubit>();
            final state = cubit.state;

            if (state is! AiTripData) return;
            if (state.destination == null || state.destination!.isEmpty) return;

            setState(() {
              _destination = state.destination!;
              _days = state.totalDays;
              _currentStep = 1;
            });
          }

          void goBack() {
            if (_currentStep == 1) {
              setState(() => _currentStep = 0);
            }
          }

          return PopScope(
            canPop: _currentStep == 0,
            onPopInvoked: (didPop) {
              if (!didPop) goBack();
            },
            child: Scaffold(
              backgroundColor: AppColors.white,
              appBar: _currentStep == 0
                  ? AppBar(
                      backgroundColor: AppColors.white,
                      elevation: 0,
                      automaticallyImplyLeading: false,
                    )
                  : null,
              body: IndexedStack(
                index: _currentStep,
                children: [
                  CustomTripInputStep(onNext: goToSplash),
                  if (_currentStep == 1)
                    CustomTripSplashScreen(
                      destination: _destination,
                      days: _days,
                    )
                  else
                    const SizedBox.shrink(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
