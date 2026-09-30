import '../constants/app_constants.dart';
import 'category_model.dart';
import 'user_model.dart';

class ProductModel {
  final int id;
  final String title;
  final String description;
  final double price;
  final double? originalPrice;
  final String conditionGrade;
  final String status;
  final String campusLocation;
  final String? imageUrl;
  final CategoryModel? category;
  final UserModel seller;
  final DateTime? createdAt;
  final bool isContactRevealed;

  ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.conditionGrade,
    required this.status,
    required this.campusLocation,
    this.imageUrl,
    this.category,
    required this.seller,
    this.createdAt,
    this.isContactRevealed = false,
  });

  bool get isAvailable => status == 'AVAILABLE';
  bool get isReserved => status == 'RESERVED';
  bool get isSold => status == 'SOLD';

  String get conditionLabel {
    switch (conditionGrade) {
      case 'NEW':
        return 'Brand New';
      case 'LIKE_NEW':
        return 'Like New';
      case 'GOOD':
        return 'Good';
      case 'FAIR':
        return 'Fair';
      default:
        return conditionGrade;
    }
  }

  int? get discountPercent {
    if (originalPrice != null && originalPrice! > price) {
      return (((originalPrice! - price) / originalPrice!) * 100).round();
    }
    return null;
  }

  String? get fullImageUrl {
    if (imageUrl == null || imageUrl!.trim().isEmpty) return null;
    final trimmed = imageUrl!.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    return '${AppConstants.defaultBaseUrl}$trimmed';
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (json['originalPrice'] as num?)?.toDouble(),
      conditionGrade: json['conditionGrade'] as String? ?? 'GOOD',
      status: json['status'] as String? ?? 'AVAILABLE',
      campusLocation: json['campusLocation'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      category: json['category'] != null ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>) : null,
      seller: json['seller'] != null ? UserModel.fromJson(json['seller'] as Map<String, dynamic>) : UserModel(id: 0, email: '', fullName: 'Seller', role: 'ROLE_STUDENT', verified: false),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
      isContactRevealed: json['contactRevealed'] as bool? ?? false,
    );
  }
}
