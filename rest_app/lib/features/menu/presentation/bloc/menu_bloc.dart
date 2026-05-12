import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rest_app/features/menu/domain/entities/cart_item_entity.dart';
import 'package:rest_app/features/menu/domain/entities/menu_item_entity.dart';
import 'package:rest_app/features/menu/domain/usecases/get_menu_items.dart';

part 'menu_event.dart';
part 'menu_state.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  final GetMenuItems getMenuItems;

  MenuBloc({required this.getMenuItems}) : super(MenuInitial()) {
    on<LoadMenuEvent>(_onLoadMenu);
    on<AddMenuItemToCartEvent>(_onAddMenuItemToCart);
    on<RemoveMenuItemFromCartEvent>(_onRemoveMenuItemFromCart);
  }

  Future<void> _onLoadMenu(LoadMenuEvent event, Emitter<MenuState> emit) async {
    emit(MenuLoading());

    try {
      final menuItems = await getMenuItems(event.menuToken);
      if (menuItems.isEmpty) {
        emit(MenuEmpty());
      } else {
        emit(MenuLoaded(menuItems: menuItems, cartItems: const []));
      }
    } catch (error) {
      emit(MenuError(error.toString()));
    }
  }

  void _onAddMenuItemToCart(
    AddMenuItemToCartEvent event,
    Emitter<MenuState> emit,
  ) {
    final state = this.state;
    if (state is! MenuLoaded) return;

    final cartItems = List<CartItemEntity>.from(state.cartItems);
    final existingIndex = cartItems.indexWhere(
      (cartItem) => cartItem.item.id == event.item.id,
    );

    if (existingIndex >= 0) {
      final existing = cartItems[existingIndex];
      cartItems[existingIndex] = existing.copyWith(
        quantity: existing.quantity + 1,
      );
    } else {
      cartItems.add(CartItemEntity(item: event.item, quantity: 1));
    }

    emit(MenuLoaded(menuItems: state.menuItems, cartItems: cartItems));
  }

  void _onRemoveMenuItemFromCart(
    RemoveMenuItemFromCartEvent event,
    Emitter<MenuState> emit,
  ) {
    final state = this.state;
    if (state is! MenuLoaded) return;

    final cartItems = List<CartItemEntity>.from(state.cartItems);
    final existingIndex = cartItems.indexWhere(
      (cartItem) => cartItem.item.id == event.item.id,
    );

    if (existingIndex < 0) return;

    final existing = cartItems[existingIndex];
    if (existing.quantity > 1) {
      cartItems[existingIndex] = existing.copyWith(
        quantity: existing.quantity - 1,
      );
    } else {
      cartItems.removeAt(existingIndex);
    }

    emit(MenuLoaded(menuItems: state.menuItems, cartItems: cartItems));
  }
}
