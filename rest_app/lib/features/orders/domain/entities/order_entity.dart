class OrderEntity {
  final String id;
  final String userId;
  final List<OrderItemEntity> items;
  final double total;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const OrderEntity({
    required this.id,
    required this.userId,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });
}

class OrderItemEntity {
  final String productId;
  final String productName;
  final int quantity;
  final double price;
  final String? notes;

  const OrderItemEntity({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    this.notes,
  });
}
