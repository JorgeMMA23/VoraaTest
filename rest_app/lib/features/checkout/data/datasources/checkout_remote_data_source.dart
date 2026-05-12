import 'package:dio/dio.dart';
import 'package:rest_app/features/checkout/data/models/order_summary_model.dart';
import 'package:rest_app/features/checkout/data/models/payment_details_model.dart';
import 'package:rest_app/features/checkout/data/models/promotion_model.dart';
import 'package:rest_app/features/menu/domain/entities/cart_item_entity.dart';

abstract class CheckoutRemoteDataSource {
  Future<PaymentDetailsModel> getPaymentDetails(List<CartItemEntity> items);
  Future<PaymentDetailsModel> requestBill({
    required String idOrder,
    String? couponId,
    required int tipPercentage,
  });
  Future<void> confirmPayment(
    String idOrder, {
    required double subtotal,
    required double discount,
    required double tip,
    required double total,
  });
  Future<List<PromotionModel>> getAvailableCoupons();
  Future<OrderSummaryModel> applyCoupon({
    required String promotionId,
    required double subtotal,
    required List<CartItemEntity> items,
  });
}

class CheckoutRemoteDataSourceImpl implements CheckoutRemoteDataSource {
  final Dio dio;

  CheckoutRemoteDataSourceImpl({required this.dio});

  @override
  Future<PaymentDetailsModel> getPaymentDetails(
    List<CartItemEntity> items,
  ) async {
    try {
      final response = await dio.post(
        '/api/orders/',
        data: {
          'items': items
              .map(
                (e) => {
                  'productId': e.item.id,
                  'productName': e.item.name,
                  'quantity': e.quantity,
                  'price': e.item.price,
                },
              )
              .toList(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return PaymentDetailsModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      throw Exception(
        'Error al obtener detalles del pago: ${response.statusCode}',
      );
    } catch (e) {
      throw Exception('Error de conexión al obtener detalles del pago: $e');
    }
  }

  @override
  Future<PaymentDetailsModel> requestBill({
    required String idOrder,
    String? couponId,
    required int tipPercentage,
  }) async {
    try {
      final couponSegment = couponId == null ? '' : '/$couponId';
      final response = await dio.post(
        '/api/orders/$idOrder/coupon$couponSegment',
        data: {'tip': '$tipPercentage%'},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return PaymentDetailsModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      throw Exception('Error al solicitar la cuenta: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error de conexion al solicitar la cuenta: $e');
    }
  }

  @override
  Future<void> confirmPayment(
    String idOrder, {
    required double subtotal,
    required double discount,
    required double tip,
    required double total,
  }) async {
    try {
      final response = await dio.patch(
        '/api/orders/$idOrder/status',
        data: {
          'status': 'paid',
          'subtotal': subtotal,
          'discount': discount,
          'tip': tip,
          'total': total,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      }

      throw Exception('Error al confirmar el pago: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error de conexion al confirmar el pago: $e');
    }
  }

  @override
  Future<List<PromotionModel>> getAvailableCoupons() async {
    try {
      final response = await dio.get('/api/promotions/');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.map((c) {
            if (c is Map<String, dynamic>) {
              return PromotionModel.fromJson(c);
            } else {
              throw Exception('Elemento no es un Map: $c');
            }
          }).toList();
        } else {
          throw Exception('La respuesta no es una lista: $data');
        }
      }

      throw Exception('Error al obtener cupones: ${response.statusCode}');
    } catch (_) {
      return [];
    }
  }

  @override
  Future<OrderSummaryModel> applyCoupon({
    required String promotionId,
    required double subtotal,
    required List<CartItemEntity> items,
  }) async {
    try {
      final response = await dio.post(
        '/api/payment/apply-coupon',
        data: {
          'promotionId': promotionId,
          'subtotal': subtotal,
          'items': items
              .map(
                (e) => {
                  'productId': e.item.id,
                  'productName': e.item.name,
                  'quantity': e.quantity,
                  'price': e.item.price,
                },
              )
              .toList(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return OrderSummaryModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      throw Exception('Error al aplicar cupón: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error de conexión al aplicar cupón: $e');
    }
  }
}
