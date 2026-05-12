import 'package:dio/dio.dart';
import 'package:rest_app/features/checkout/data/models/payment_details_model.dart';
import 'package:rest_app/features/orders/data/models/order_model.dart';

abstract class OrdersRemoteDataSource {
  Future<List<PaymentDetailsModel>> getUserOrders();
  Future<OrderModel> createOrder(List<OrderItemModel> items);
  Future<void> requestHelp(String orderId);
}

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  final Dio dio;

  OrdersRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<PaymentDetailsModel>> getUserOrders() async {
    try {
      final response = await dio.get('/api/orders/');

      if (response.statusCode == 200) {
        final List<dynamic> ordersJson = response.data as List<dynamic>;
        return ordersJson
            .map(
              (orderJson) => PaymentDetailsModel.fromJson(
                orderJson as Map<String, dynamic>,
              ),
            )
            .toList();
      } else {
        throw Exception('Error al obtener las órdenes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  @override
  Future<OrderModel> createOrder(List<OrderItemModel> items) async {
    try {
      final total = items.fold<double>(
        0,
        (sum, item) => sum + item.price * item.quantity,
      );

      final response = await dio.post(
        '/api/orders/',
        data: {
          'items': items.map((item) => item.toJson()).toList(),
          'total': total,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return OrderModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw Exception('Error al crear la orden: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error de conexión al crear la orden: $e');
    }
  }

  @override
  Future<void> requestHelp(String orderId) async {
    try {
      final response = await dio.post('/api/orders/$orderId/help');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      }

      throw Exception('Error al solicitar ayuda: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error de conexión al solicitar ayuda: $e');
    }
  }
}
