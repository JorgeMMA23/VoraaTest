import 'package:equatable/equatable.dart';
import 'package:rest_app/features/menu/domain/entities/menu_item_entity.dart';

class CartItemEntity extends Equatable {
  final MenuItemEntity item;
  final int quantity;

  const CartItemEntity({required this.item, required this.quantity});

  CartItemEntity copyWith({int? quantity}) {
    return CartItemEntity(item: item, quantity: quantity ?? this.quantity);
  }

  @override
  List<Object?> get props => [item, quantity];
}
