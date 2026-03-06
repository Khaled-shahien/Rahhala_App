// lib/features/custom_trip/data/models/transportation_model.dart

import 'package:equatable/equatable.dart';

class TransportationModel extends Equatable {
  final String from;
  final String to;
  final String method;
  final String estimatedCost;

  const TransportationModel({
    required this.from,
    required this.to,
    required this.method,
    required this.estimatedCost,
  });

  factory TransportationModel.fromJson(Map<String, dynamic> json) {
    return TransportationModel(
      from: json['from'] ?? '',
      to: json['to'] ?? '',
      method: json['method'] ?? '',
      estimatedCost: json['estimatedCost'] ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'from': from,
      'to': to,
      'method': method,
      'estimatedCost': estimatedCost,
    };
  }

  @override
  List<Object?> get props => [from, to, method, estimatedCost];
}
