import 'package:dio/dio.dart';

abstract class WaiterRemoteDataSource {
  Future<void> updateToken({required String waiterId, required String token});
  Future<double> getTotalTips();
}

class WaiterRemoteDataSourceImpl implements WaiterRemoteDataSource {
  final Dio dio;

  WaiterRemoteDataSourceImpl({required this.dio});

  @override
  Future<void> updateToken({
    required String waiterId,
    required String token,
  }) async {
    try {
      final response = await dio.patch(
        '/api/waiters/$waiterId/token',
        data: {'tokenDevice': token},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      }

      throw Exception('Error al actualizar token: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error de conexión al actualizar token: $e');
    }
  }

  @override
  Future<double> getTotalTips() async {
    try {
      final response = await dio.get('/api/orders/tips/paid');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final raw = data['totalTips'];
        if (raw is num) return raw.toDouble();
        if (raw is String) return double.tryParse(raw) ?? 0.0;
        return 0.0;
      }

      throw Exception('Error al obtener propinas: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error de conexión al obtener propinas: $e');
    }
  }
}
