// import 'package:rest_app/features/checkout/domain/entities/coupon_entity.dart';

// class PromotionModel extends CouponEntity {
//   const PromotionModel({
//     required super.id,
//     required super.title,
//     required super.description,
//     required super.discountPercentage,
//     required super.startDate,
//     required super.endDate,
//     required super.active,
//     required super.createdAt,
//   });

//   factory PromotionModel.fromJson(Map<String, dynamic> json) {
//     return PromotionModel(
//       id: json['id'] as String,
//       title: json['title'] as String,
//       description: json['description'] as String,
//       discountPercentage: (json['discountPercentage'] as num).toDouble(),
//       startDate: DateTime.parse(json['startDate'] as String),
//       endDate: DateTime.parse(json['endDate'] as String),
//       active: json['active'] as bool,
//       createdAt: DateTime.parse(json['createdAt'] as String),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'title': title,
//       'description': description,
//       'discountPercentage': discountPercentage,
//       'startDate': startDate.toIso8601String(),
//       'endDate': endDate.toIso8601String(),
//       'active': active,
//       'createdAt': createdAt.toIso8601String(),
//     };
//   }
// }
