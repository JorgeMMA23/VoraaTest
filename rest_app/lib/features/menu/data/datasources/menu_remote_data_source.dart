import 'package:dio/dio.dart';
import 'package:rest_app/features/menu/data/models/menu_item_model.dart';

abstract class MenuRemoteDataSource {
  Future<List<MenuItemModel>> getMenuItems(String menuToken);
}

class MenuRemoteDataSourceImpl implements MenuRemoteDataSource {
  final Dio dio;

  MenuRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<MenuItemModel>> getMenuItems(String menuToken) async {
    try {
      final response = await dio.get('/api/menu/');

      if (response.statusCode == 200) {
        final List<dynamic> menuJson = response.data as List<dynamic>;
        return menuJson
            .map(
              (itemJson) =>
                  MenuItemModel.fromJson(itemJson as Map<String, dynamic>),
            )
            .toList();
      }

      throw Exception('Error al obtener el menú: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error de conexión al cargar el menú: $e');
    }
  }
}
