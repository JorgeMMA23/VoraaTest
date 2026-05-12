import 'package:equatable/equatable.dart';

class PromotionEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final double discountPercentage;
  final DateTime startDate;
  final DateTime endDate;
  final bool active;
  final DateTime createdAt;

  const PromotionEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.discountPercentage,
    required this.startDate,
    required this.endDate,
    required this.active,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    discountPercentage,
    startDate,
    endDate,
    active,
    createdAt,
  ];
}
