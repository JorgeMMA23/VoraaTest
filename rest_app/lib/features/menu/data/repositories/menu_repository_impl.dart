import 'package:rest_app/features/menu/data/datasources/menu_remote_data_source.dart';
import 'package:rest_app/features/menu/domain/entities/menu_item_entity.dart';
import 'package:rest_app/features/menu/domain/repositories/menu_repository.dart';

class MenuRepositoryImpl implements MenuRepository {
  final MenuRemoteDataSource remoteDataSource;

  MenuRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<MenuItemEntity>> getMenuItems(String menuToken) {
    return remoteDataSource.getMenuItems(menuToken);
  }
}
