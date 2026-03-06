// lib/features/custom_trip/domain/entities/activity_entity.dart

import 'package:equatable/equatable.dart';
import 'transportation_entity.dart';

class ActivityEntity extends Equatable {
  final String time;
  final String place;
  final String description;
  final String estimatedCost;
  final List<TransportationEntity> transportation;

  const ActivityEntity({
    required this.time,
    required this.place,
    required this.description,
    required this.estimatedCost,
    required this.transportation,
  });

  @override
  List<Object?> get props => [
        time,
        place,
        description,
        estimatedCost,
        transportation,
      ];
}
