import 'package:rest_app/features/checkout/domain/entities/promotion_entity.dart';

class PromotionModel extends PromotionEntity {
  const PromotionModel({
    required super.id,
    required super.title,
    required super.description,
    required super.discountPercentage,
    required super.startDate,
    required super.endDate,
    required super.active,
    required super.createdAt,
  });

  factory PromotionModel.fromJson(Map<String, dynamic> json) {
    return PromotionModel(
      id: _parseString(json['id']),
      title: _parseString(json['title']),
      description: _parseString(json['description']),
      discountPercentage: _parseDouble(json['discountPercentage']),
      startDate: _parseDateTime(json['startDate']),
      endDate: _parseDateTime(json['endDate']),
      active: _parseBool(json['active']),
      createdAt: _parseDateTime(json['createdAt']),
    );
  }

  static String _parseString(dynamic value) {
    if (value is String) return value;
    if (value != null) return value.toString();
    return '';
  }

  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is num) return value != 0;
    return false;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    if (value is Map<String, dynamic>) {
      final seconds = value['_seconds'];
      final nanoseconds = value['_nanoseconds'];
      if (seconds is int && nanoseconds is int) {
        return DateTime.fromMillisecondsSinceEpoch(
          seconds * 1000 + nanoseconds ~/ 1000000,
          isUtc: true,
        );
      }
    }
    throw FormatException('No se pudo parsear la fecha: $value');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'discountPercentage': discountPercentage,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'active': active,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
