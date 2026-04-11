import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    // بنجيب الـ ColorScheme بتاعنا
    final colorScheme = Theme.of(context).colorScheme;

    return BlocProvider(
      create: (_) => sl<CustomTripCubit>(),
      child: Builder(
        builder: (innerContext) {
          void goToSplash() {
            final cubit = innerContext.read<CustomTripCubit>();
            if (cubit.selectedRegion == null || cubit.selectedRegion!.isEmpty) {
              return;
            }
            cubit.generateTripPlan();
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => CustomTripSplashScreen(cubit: cubit)),
            );
          }

          return PopScope(
            canPop: true,
            onPopInvoked: (didPop) {
              if (didPop) innerContext.read<CustomTripCubit>().reset();
            },
            child: Theme(
              data: Theme.of(context).copyWith(
                textTheme: Theme.of(context).textTheme.apply(
                      bodyColor: Colors.white,
                      displayColor: Colors.white,
                    ),
              ),
              child: Scaffold(
                backgroundColor: colorScheme.surface,
                appBar: AppBar(
                  backgroundColor: colorScheme.primary,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_outlined,
                        color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                  ),
                ),
                body: CustomTripInputStep(onNext: goToSplash),
              ),
            ),
          );
        },
      ),
    );
  }
}
