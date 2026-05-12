import 'package:rest_app/features/orders/domain/entities/order_entity.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.userId,
    required super.items,
    required super.total,
    required super.status,
    required super.createdAt,
    super.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    print(json);
    return OrderModel(
      id: json['id'] as String,
      userId: json['userId'].toString(),
      items:
          (json['items'] as List<dynamic>?)
              ?.map(
                (item) => OrderItemModel.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      total: (json['total'] as num).toDouble(),
      status: json['status'].toString(),
      createdAt:
          DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'items': items.map((item) => (item as OrderItemModel).toJson()).toList(),
    'total': total,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };
}

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.productId,
    required super.productName,
    required super.quantity,
    required super.price,
    super.notes,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
      notes: json['notes'] as String?,
    );
  }

  factory OrderItemModel.fromEntity(OrderItemEntity entity) {
    return OrderItemModel(
      productId: entity.productId,
      productName: entity.productName,
      quantity: entity.quantity,
      price: entity.price,
      notes: entity.notes,
    );
  }

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'productName': productName,
    'quantity': quantity,
    'price': price,
    'notes': notes,
  };
}
