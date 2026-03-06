import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rahhala_app/core/constants/app_colors.dart';
import 'package:rahhala_app/core/di/service_locator.dart';
import 'package:rahhala_app/features/custom_trip/presentation/cubit/custom_trip_cubit.dart';
import 'package:rahhala_app/features/custom_trip/presentation/pages/custom_trip_splash_screen.dart';
import 'package:rahhala_app/features/custom_trip/presentation/widgets/custom_trip_input_step.dart';

class CustomTripFlowScreen extends StatefulWidget {
  const CustomTripFlowScreen({super.key});

  @override
  State<CustomTripFlowScreen> createState() => _CustomTripFlowScreenState();
}

class _CustomTripFlowScreenState extends State<CustomTripFlowScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CustomTripCubit>(),
      child: Builder(
        builder: (innerContext) {
          void goToSplash() {
            final cubit = innerContext.read<CustomTripCubit>();

            // Check if region is selected
            if (cubit.selectedRegion == null || cubit.selectedRegion!.isEmpty) {
              return;
            }

            // Call the API to generate trip plan
            cubit.generateTripPlan();

            // Navigate to splash screen which will listen for the result
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CustomTripSplashScreen(cubit: cubit),
              ),
            );
          }

          return PopScope(
            canPop: true,
            onPopInvoked: (didPop) {
              if (didPop) {
                // Reset cubit when navigating back to this screen
                context.read<CustomTripCubit>().reset();
              }
            },
            child: Scaffold(
              backgroundColor: AppColors.white,
              appBar: AppBar(
                backgroundColor: AppColors.white,
                elevation: 0,
                automaticallyImplyLeading: false,
              ),
              body: CustomTripInputStep(onNext: goToSplash),
            ),
          );
        },
      ),
    );
  }
}
