import 'package:equatable/equatable.dart';

class MenuItemEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final String? category;

  const MenuItemEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    this.category,
  });

  @override
  List<Object?> get props => [id, name, description, price, imageUrl, category];
}
