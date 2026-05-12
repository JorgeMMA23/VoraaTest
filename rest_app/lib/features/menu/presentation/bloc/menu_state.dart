part of 'menu_bloc.dart';

abstract class MenuState extends Equatable {
  const MenuState();

  @override
  List<Object?> get props => [];
}

class MenuInitial extends MenuState {}

class MenuLoading extends MenuState {}

class MenuLoaded extends MenuState {
  final List<MenuItemEntity> menuItems;
  final List<CartItemEntity> cartItems;

  const MenuLoaded({required this.menuItems, required this.cartItems});

  double get totalPrice => cartItems.fold(
    0,
    (previousValue, item) => previousValue + item.item.price * item.quantity,
  );

  int get totalItems =>
      cartItems.fold(0, (previousValue, item) => previousValue + item.quantity);

  @override
  List<Object?> get props => [menuItems, cartItems];
}

class MenuEmpty extends MenuState {}

class MenuError extends MenuState {
  final String message;

  const MenuError(this.message);

  @override
  List<Object?> get props => [message];
}
