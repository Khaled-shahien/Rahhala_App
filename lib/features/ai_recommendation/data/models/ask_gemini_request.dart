import 'package:equatable/equatable.dart';

class AskGeminiRequest extends Equatable {
  final String country;
  final int numberOfDays;
  final String budget;
  final List<String> interestTypes;
  final String season;

  const AskGeminiRequest({
    required this.country,
    required this.numberOfDays,
    required this.budget,
    required this.interestTypes,
    required this.season,
  });

  Map<String, dynamic> toJson() {
    return {
      'country': country,
      'NumberOfDays': numberOfDays,
      'Budget': budget,
      'InterestTypes': interestTypes,
      'Season': season,
    };
  }

  @override
  List<Object?> get props =>
      [country, numberOfDays, budget, interestTypes, season];
}
