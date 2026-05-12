import 'package:rest_app/features/menu/domain/entities/menu_item_entity.dart';
import 'package:rest_app/features/menu/domain/repositories/menu_repository.dart';

class GetMenuItems {
  final MenuRepository repository;

  GetMenuItems(this.repository);

  Future<List<MenuItemEntity>> call(String menuToken) {
    return repository.getMenuItems(menuToken);
  }
}
