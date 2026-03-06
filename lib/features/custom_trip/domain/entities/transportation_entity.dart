// lib/features/custom_trip/domain/entities/transportation_entity.dart

import 'package:equatable/equatable.dart';

class TransportationEntity extends Equatable {
  final String from;
  final String to;
  final String method;
  final String estimatedCost;

  const TransportationEntity({
    required this.from,
    required this.to,
    required this.method,
    required this.estimatedCost,
  });

  @override
  List<Object?> get props => [from, to, method, estimatedCost];
}
