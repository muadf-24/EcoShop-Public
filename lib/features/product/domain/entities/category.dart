import 'package:equatable/equatable.dart';

/// Category entity
class Category extends Equatable {
  final String id;
  final String name;
  final String? iconName;
  final String? imageUrl;
  final int productCount;

  const Category({
    required this.id,
    required this.name,
    this.iconName,
    this.imageUrl,
    this.productCount = 0,
  });

  @override
  List<Object?> get props => [id, name, iconName, imageUrl, productCount];
}
