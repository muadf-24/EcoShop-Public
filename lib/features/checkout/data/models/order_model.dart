import '../../domain/entities/order.dart';
import '../../../profile/domain/entities/address.dart';
import 'address_model.dart';

class OrderModel extends Order {
  const OrderModel({
    required super.id,
    required super.items,
    required super.subtotal,
    required super.tax,
    required super.shipping,
    super.discount,
    required super.total,
    required super.status,
    required super.shippingAddress,
    required super.paymentMethod,
    required super.createdAt,
    super.estimatedDelivery,
  });

  @override
  OrderModel copyWith({
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
    return OrderModel(
      id: id ?? this.id,
      items: (items ?? this.items).map((e) => e as OrderItemModel).toList(),
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

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      items: (json['items'] as List)
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      shipping: (json['shipping'] as num).toDouble(),
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num).toDouble(),
      status: json['status'] as String,
      shippingAddress: AddressModel.fromJson(
        json['shipping_address'] as Map<String, dynamic>,
      ),
      paymentMethod: json['payment_method'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      estimatedDelivery: json['estimated_delivery'] != null
          ? DateTime.parse(json['estimated_delivery'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items
          .map((e) => {
                'product_id': e.productId,
                'product_name': e.productName,
                'product_image': e.productImage,
                'price': e.price,
                'quantity': e.quantity,
              })
          .toList(),
      'subtotal': subtotal,
      'tax': tax,
      'shipping': shipping,
      'discount': discount,
      'total': total,
      'status': status,
      'shipping_address': AddressModel.fromEntity(shippingAddress).toJson(),
      'payment_method': paymentMethod,
      'created_at': createdAt.toIso8601String(),
      'estimated_delivery': estimatedDelivery?.toIso8601String(),
    };
  }
}

class OrderItemModel extends OrderItem {
  const OrderItemModel({
    required super.productId,
    required super.productName,
    required super.productImage,
    required super.price,
    required super.quantity,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      productImage: json['product_image'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
    );
  }
}
