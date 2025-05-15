class Order {
  final String id;
  final String userId;
  final double totalAmount;
  final String status;
  final String shippingAddress;
  final DateTime createdAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.userId,
    required this.totalAmount,
    required this.status,
    required this.shippingAddress,
    required this.createdAt,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'].toString(),
      userId: json['user_id'],
      totalAmount: (json['total_amount'] as num).toDouble(),
      status: json['status'] ?? 'pending',
      shippingAddress: json['shipping_address'],
      createdAt: DateTime.parse(json['created_at']),
      items: (json['order_items'] as List?)
              ?.map((item) => OrderItem.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'total_amount': totalAmount,
      'status': status,
      'shipping_address': shippingAddress,
      'created_at': createdAt.toIso8601String(),
      'order_items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class OrderItem {
  final String id;
  final String orderId;
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String? imageUrl;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    this.imageUrl,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'].toString(),
      orderId: json['order_id'].toString(),
      productId: json['product_id'].toString(),
      productName: json['product_name'],
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'],
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'product_name': productName,
      'price': price,
      'quantity': quantity,
      'image_url': imageUrl,
    };
  }
} 