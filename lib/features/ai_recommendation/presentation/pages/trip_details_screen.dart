import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:rahhala_app/core/di/service_locator.dart';
import 'package:rahhala_app/core/logging/app_logger.dart';
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
    this.showActions = true,
  });

  final TripPlanResponse tripPlan;
  final Map<String, dynamic> geminiRequest;
  final bool showActions;

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
    } catch (e) {
      AppLogger.instance.w('TripDetailsScreen: Save trip failed', error: e);
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
                              'coordinates': activity.coordinates,
                              'description': activity.description,
                              'estimatedCost': activity.estimatedCost,
                              'image': activity.image,
                              'transportation':
                                  activity.transportation.map((transport) {
                                return {
                                  'from': transport.from,
                                  'to': transport.to,
                                  'method': transport.method,
                                  'estimatedCost': transport.estimatedCost,
                                };
                              }).toList(),
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
    } catch (e) {
      AppLogger.instance
          .w('TripDetailsScreen: Regenerate trip failed', error: e);
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
        final theme = Theme.of(dialogContext);
        final isDark = theme.brightness == Brightness.dark;

        return AlertDialog(
          backgroundColor:
              Theme.of(dialogContext).dialogTheme.backgroundColor ??
                  theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            TripDetailsStrings.regenerateTitle,
            style: TextStyle(
              color: theme.textTheme.titleLarge?.color ?? primaryTextColor,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            TripDetailsStrings.regenerateBody,
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color ?? primaryTextColor,
              fontSize: 14.sp,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                TripDetailsStrings.cancel,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey,
                  fontSize: 14.sp,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                unawaited(_regenerateTrip());
              },
              child: Text(
                TripDetailsStrings.regenerate,
                style: TextStyle(
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final customBgColor =
        isDark ? const Color(0xFF121212) : theme.scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: customBgColor,
      extendBodyBehindAppBar: true,
      bottomNavigationBar: widget.showActions
          ? TripSaveButton(
              isSaving: _isSaving,
              onSave: _saveTrip,
            )
          : null,
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
                showRegenerate: widget.showActions,
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
                        emergencyContact: '',
                      ),
                      _buildEmergencyContactSection(
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

  Widget _buildEmergencyContactSection({required String emergencyContact}) {
    if (emergencyContact.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final contacts = emergencyContact.split(',');

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.red.withValues(alpha: 0.1)
                        : lightBorderColor.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.emergency_outlined,
                      color: Colors.red.shade400, size: 24.sp),
                ),
                SizedBox(width: 16.w),
                Text(
                  'Emergency Contacts',
                  style: TextStyle(
                    color:
                        theme.textTheme.titleMedium?.color ?? primaryTextColor,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: contacts.map((contact) {
                final parts = contact.trim().split(':');
                final label = parts.isNotEmpty ? parts[0].trim() : '';
                final number = parts.length > 1 ? parts[1].trim() : '';
                return Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : lightBorderColor.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                        color: theme.dividerColor.withValues(alpha: 0.2),
                        width: 1),
                  ),
                  child: IntrinsicWidth(
                    child: Row(
                      children: [
                        Icon(Icons.phone_outlined,
                            size: 14.sp, color: Colors.red.shade400),
                        SizedBox(width: 6.w),
                        Flexible(
                          child: Text(
                            '$label${number.isNotEmpty ? ': $number' : ''}',
                            style: TextStyle(
                              color: theme.textTheme.bodyMedium?.color ??
                                  primaryTextColor,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class TimelineWrapper extends StatelessWidget {
  final Widget child;
  final bool isFirst;
  final bool isLast;

  const TimelineWrapper({
    super.key,
    required this.child,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final lineMainColor =
        isDark ? theme.primaryColor.withValues(alpha: 0.3) : (timelineColor);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 40.w,
            child: Column(
              children: [
                Container(
                  height: 25.h,
                  width: 2,
                  color: isFirst ? Colors.transparent : lineMainColor,
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLast ? Colors.transparent : lineMainColor,
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
