import 'package:equatable/equatable.dart';
import '../../../profile/domain/entities/address.dart';

/// Order entity
class Order extends Equatable {
  final String id;
  final List<OrderItem> items;
  final double subtotal;
  final double tax;
  final double shipping;
  final double discount;
  final double total;
  final String status;
  final Address shippingAddress;
  final String paymentMethod;
  final DateTime createdAt;
  final DateTime? estimatedDelivery;

  const Order({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.shipping,
    this.discount = 0,
    required this.total,
    required this.status,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.createdAt,
    this.estimatedDelivery,
  });

  Order copyWith({
    String? id,
    List<OrderItem>? items,
    double? subtotal,
    double? tax,
    double? shipping,
    double? discount,
    double? total,
    String? status,
    Address? shippingAddress,
    String? paymentMethod,
    DateTime? createdAt,
    DateTime? estimatedDelivery,
  }) {
    return Order(
      id: id ?? this.id,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      shipping: shipping ?? this.shipping,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      status: status ?? this.status,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
    );
  }

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  @override
  List<Object?> get props => [
        id, items, subtotal, tax, shipping, discount,
        total, status, shippingAddress, paymentMethod,
        createdAt, estimatedDelivery,
      ];
}

/// Order item (snapshot of product at time of purchase)
class OrderItem extends Equatable {
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
  });

  double get total => price * quantity;

  @override
  List<Object?> get props => [productId, productName, productImage, price, quantity];
}
