import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rahhala_app/core/di/service_locator.dart';
import 'package:rahhala_app/core/utils/app_notifications.dart';
import 'package:rahhala_app/core/widgets/background_decorator.dart';
import 'package:rahhala_app/features/ai_recommendation/data/models/trip_plan_model.dart';
import 'package:rahhala_app/features/ai_recommendation/data/repositories/gemini_repository.dart';
import 'package:rahhala_app/features/ai_recommendation/presentation/widgets/trip_details/trip_day_section.dart';
import 'package:rahhala_app/features/ai_recommendation/presentation/widgets/trip_details/trip_details_header.dart';
import 'package:rahhala_app/features/ai_recommendation/presentation/widgets/trip_details/trip_details_theme.dart';
import 'package:rahhala_app/features/ai_recommendation/presentation/widgets/trip_details/trip_info_sections.dart';
import 'package:rahhala_app/features/ai_recommendation/presentation/widgets/trip_details/trip_save_button.dart';

class TripDetailsScreen extends StatefulWidget {
  const TripDetailsScreen({
    super.key,
    required this.tripPlan,
    required this.geminiRequest,
  });

  final TripPlanResponse tripPlan;
  final Map<String, dynamic> geminiRequest;

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  bool _isSaving = false;
  bool _isRegenerating = false;
  late TripPlanResponse _currentTripPlan;

  @override
  void initState() {
    super.initState();
    _currentTripPlan = widget.tripPlan;
  }

  TripPlan get plan => _currentTripPlan.response;

  Future<void> _saveTrip() async {
    if (_isSaving) {
      return;
    }
    setState(() => _isSaving = true);

    try {
      final repo = sl<GeminiRepository>();
      final result = await repo.saveTripPlan(
        tripPlan: _currentTripPlan,
        geminiRequest: widget.geminiRequest,
      );

      if (!mounted) {
        return;
      }

      result.fold(
        (failure) {
          HapticFeedback.mediumImpact();
          showAppNotification(
            context: context,
            title: 'Error',
            message: failure.message,
            isError: true,
          );
        },
        (data) {
          if (data['success'] == true) {
            final savedTripId = data['tripId'] ?? 'N/A';
            showAppNotification(
              context: context,
              title: 'Saved',
              message:
                  '${data['message'] ?? TripDetailsStrings.saveSuccessFallback}\n'
                  'Trip ID: $savedTripId',
            );
            return;
          }

          HapticFeedback.mediumImpact();
          showAppNotification(
            context: context,
            title: 'Error',
            message: data['message'] ?? 'Error occurred',
            isError: true,
          );
        },
      );
    } catch (_) {
      if (mounted) {
        HapticFeedback.mediumImpact();
        showAppNotification(
          context: context,
          title: 'Error',
          message: TripDetailsStrings.saveFailed,
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _regenerateTrip() async {
    if (_isRegenerating) {
      return;
    }
    setState(() => _isRegenerating = true);

    try {
      final repo = sl<GeminiRepository>();

      final requestBody = {
        'success': true,
        'tripData': {
          'destination': plan.destination,
          'days': plan.days
              .map((day) => {
                    'day': day.day,
                    'title': day.title,
                    'estimatedDayCost': day.estimatedDayCost,
                    'activities': day.activities
                        .map((activity) => {
                              'time': activity.time,
                              'place': activity.place,
                              'description': activity.description,
                              'estimatedCost': activity.estimatedCost,
                              'image': activity.image,
                              'transportation': [],
                            })
                        .toList(),
                  })
              .toList(),
          'totalEstimatedCost': plan.totalEstimatedCost,
          'budgetTips': plan.budgetTips,
          'travelTips': plan.travelTips,
          'emergencycontact': plan.emergencyContact,
          'tripId': '00000000-0000-0000-0000-000000000000',
        },
        'geminiRequest': widget.geminiRequest,
      };

      final result = await repo.regenerateTripPlan(requestBody);

      if (!mounted) {
        return;
      }

      result.fold(
        (failure) {
          HapticFeedback.mediumImpact();
          showAppNotification(
            context: context,
            title: 'Error',
            message: failure.message,
            isError: true,
          );
        },
        (data) {
          if (data['success'] == true && data['tripData'] != null) {
            final newPlan = TripPlan.fromJson(data['tripData']);
            final newResponse = TripPlanResponse(
              success: true,
              response: newPlan,
              savedId: 0,
              tripId: _currentTripPlan.tripId,
              message: 'Trip regenerated successfully',
              geminiRequest: widget.geminiRequest,
            );

            showAppNotification(
              context: context,
              title: 'Success',
              message: TripDetailsStrings.tripRegenerated,
            );

            setState(() {
              _currentTripPlan = newResponse;
            });
            return;
          }

          HapticFeedback.mediumImpact();
          showAppNotification(
            context: context,
            title: 'Error',
            message: data['message'] ?? 'Failed to regenerate trip',
            isError: true,
          );
        },
      );
    } catch (_) {
      if (mounted) {
        HapticFeedback.mediumImpact();
        showAppNotification(
          context: context,
          title: 'Error',
          message: TripDetailsStrings.regenerateFailed,
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRegenerating = false);
      }
    }
  }

  void _showRegenerateDialog() {
    unawaited(showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Text(
            TripDetailsStrings.regenerateTitle,
            style: TextStyle(
              color: primaryTextColor,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            TripDetailsStrings.regenerateBody,
            style: TextStyle(color: primaryTextColor, fontSize: 14.sp),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                TripDetailsStrings.cancel,
                style: TextStyle(color: Colors.grey, fontSize: 14.sp),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                unawaited(_regenerateTrip());
              },
              child: Text(
                TripDetailsStrings.regenerate,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBackgroundColor,
      extendBodyBehindAppBar: true,
      bottomNavigationBar: TripSaveButton(
        isSaving: _isSaving,
        onSave: _saveTrip,
      ),
      body: SafeArea(
        top: false,
        child: BackgroundDecorator(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TripDetailsHeader(
                plan: plan,
                isRegenerating: _isRegenerating,
                onBack: () => Navigator.pop(context),
                onRegenerate: _showRegenerateDialog,
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    children: [
                      SizedBox(height: 16.h),
                      ...plan.days.map((day) => TripDaySection(day: day)),
                      SizedBox(height: 16.h),
                      TripInfoSections(
                        budgetTips: plan.budgetTips,
                        travelTips: plan.travelTips,
                        emergencyContact: plan.emergencyContact,
                      ),
                      SizedBox(height: 32.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
