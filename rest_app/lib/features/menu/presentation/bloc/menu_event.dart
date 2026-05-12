part of 'menu_bloc.dart';

abstract class MenuEvent extends Equatable {
  const MenuEvent();

  @override
  List<Object?> get props => [];
}

class LoadMenuEvent extends MenuEvent {
  final String menuToken;

  const LoadMenuEvent({required this.menuToken});

  @override
  List<Object?> get props => [menuToken];
}

class AddMenuItemToCartEvent extends MenuEvent {
  final MenuItemEntity item;

  const AddMenuItemToCartEvent(this.item);

  @override
  List<Object?> get props => [item];
}

class RemoveMenuItemFromCartEvent extends MenuEvent {
  final MenuItemEntity item;

  const RemoveMenuItemFromCartEvent(this.item);

  @override
  List<Object?> get props => [item];
}
