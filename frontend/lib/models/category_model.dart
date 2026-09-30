import 'package:flutter/material.dart';

class CategoryModel {
  final int id;
  final String name;
  final String slug;
  final String iconName;
  final int displayOrder;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.iconName,
    required this.displayOrder,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      iconName: json['iconName'] as String? ?? 'category',
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
    );
  }

  // Fallback categories if database has not yet been seeded
  static List<CategoryModel> get defaultCategories => [
    CategoryModel(id: 1, name: 'Textbooks', slug: 'textbooks', iconName: 'menu_book', displayOrder: 1),
    CategoryModel(id: 2, name: 'Electronics', slug: 'electronics', iconName: 'laptop_mac', displayOrder: 2),
    CategoryModel(id: 3, name: 'Dorm & Living', slug: 'dorm', iconName: 'chair', displayOrder: 3),
    CategoryModel(id: 4, name: 'Lab Gear', slug: 'lab-gear', iconName: 'science', displayOrder: 4),
    CategoryModel(id: 5, name: 'Mobility & Bikes', slug: 'mobility', iconName: 'directions_bike', displayOrder: 5),
    CategoryModel(id: 6, name: 'Clothing', slug: 'clothing', iconName: 'checkroom', displayOrder: 6),
  ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  // Minimal clean Material Icons fallback (no AI images)
  IconData get iconData {
    switch (slug) {
      case 'textbooks':
        return Icons.menu_book_rounded;
      case 'electronics':
        return Icons.laptop_mac_rounded;
      case 'dorm':
        return Icons.chair_rounded;
      case 'lab-gear':
        return Icons.science_rounded;
      case 'mobility':
        return Icons.directions_bike_rounded;
      case 'clothing':
        return Icons.checkroom_rounded;
      default:
        return Icons.category_rounded;
    }
  }
}
