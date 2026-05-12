import 'package:rest_app/features/checkout/domain/entities/payment_details_entity.dart';
import 'package:rest_app/features/orders/data/models/order_model.dart';

class PaymentDetailsModel extends PaymentDetailsEntity {
  const PaymentDetailsModel({
    required super.id,
    required super.subtotal,
    super.discount,
    super.taxes,
    required super.tip,
    required super.total,
    required super.status,
    required super.paymentStatus,
    required super.items,
    required super.createdAt,
    required super.updatedAt,
    super.currency,
    super.calculations,
    super.appliedPromotion,
  });

  factory PaymentDetailsModel.fromJson(Map<String, dynamic> json) {
    final items =
        (json['items'] as List<dynamic>?)
            ?.map(
              (item) => OrderItemModel.fromJson(item as Map<String, dynamic>),
            )
            .toList() ??
        [];
    return PaymentDetailsModel(
      id: json['id'] as String,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      taxes:
          (json['taxes'] as num?)?.toDouble() ??
          (json['tax'] as num?)?.toDouble() ??
          0.0,
      tip: (json['tip'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? 'pending',
      paymentStatus: json['paymentStatus'] as String? ?? 'pending',
      items: items,
      createdAt:
          DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now(),
      currency: json['currency'] as String? ?? 'MXN',
      calculations: json['calculations'] != null
          ? PaymentCalculationsModel.fromJson(
              json['calculations'] as Map<String, dynamic>,
            )
          : null,
      appliedPromotion:
          json['appliedPromotion'] != null || json['promotion'] != null
          ? AppliedPromotionModel.fromJson(
              (json['appliedPromotion'] ?? json['promotion'])
                  as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class PaymentCalculationsModel extends PaymentCalculationsEntity {
  const PaymentCalculationsModel({
    required super.subtotal,
    required super.discount,
    required super.selectedTip,
    required super.total,
    required super.totalWithoutTip,
    required super.tipOptions,
  });

  factory PaymentCalculationsModel.fromJson(Map<String, dynamic> json) {
    final tipOptionsJson = json['tipOptions'] as Map<String, dynamic>? ?? {};

    return PaymentCalculationsModel(
      subtotal: _parseDouble(json['subtotal']),
      discount: _parseDouble(json['discount']),
      selectedTip: _parseTip(json['selectedTip']),
      total: _parseDouble(json['total']),
      totalWithoutTip: _parseDouble(json['totalWithoutTip']),
      tipOptions: tipOptionsJson.map(
        (key, value) => MapEntry(
          key,
          TipOptionModel.fromJson(value as Map<String, dynamic>),
        ),
      ),
    );
  }
}

class TipOptionModel extends TipOptionEntity {
  const TipOptionModel({
    required super.percentage,
    required super.tip,
    required super.total,
  });

  factory TipOptionModel.fromJson(Map<String, dynamic> json) {
    return TipOptionModel(
      percentage: _parseInt(json['percentage']),
      tip: _parseDouble(json['tip']),
      total: _parseDouble(json['total']),
    );
  }
}

class AppliedPromotionModel extends AppliedPromotionEntity {
  const AppliedPromotionModel({super.promotion, super.applied});

  factory AppliedPromotionModel.fromJson(Map<String, dynamic> json) {
    return AppliedPromotionModel(applied: _parseBool(json['applied']));
  }
}

String _parseTip(dynamic value) {
  if (value is String) return value;
  if (value is num) return '${value.toInt()}%';
  return '0%';
}

double _parseDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

bool _parseBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) return value.toLowerCase() == 'true';
  return false;
}
