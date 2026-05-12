import 'package:rest_app/features/menu/domain/entities/menu_item_entity.dart';

abstract class MenuRepository {
  Future<List<MenuItemEntity>> getMenuItems(String menuToken);
}
