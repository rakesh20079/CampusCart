class ContactDetailsModel {
  final int productId;
  final String productTitle;
  final String sellerName;
  final String sellerEmail;
  final String? sellerPhone;
  final String? sellerWhatsapp;
  final String campusLocation;
  final String safetyTip;
  final DateTime? revealedAt;

  ContactDetailsModel({
    required this.productId,
    required this.productTitle,
    required this.sellerName,
    required this.sellerEmail,
    this.sellerPhone,
    this.sellerWhatsapp,
    required this.campusLocation,
    required this.safetyTip,
    this.revealedAt,
  });

  factory ContactDetailsModel.fromJson(Map<String, dynamic> json) {
    return ContactDetailsModel(
      productId: json['productId'] as int? ?? 0,
      productTitle: json['productTitle'] as String? ?? '',
      sellerName: json['sellerName'] as String? ?? 'Seller',
      sellerEmail: json['sellerEmail'] as String? ?? '',
      sellerPhone: json['sellerPhone'] as String?,
      sellerWhatsapp: json['sellerWhatsapp'] as String?,
      campusLocation: json['campusLocation'] as String? ?? '',
      safetyTip: json['safetyTip'] as String? ?? '',
      revealedAt: json['revealedAt'] != null ? DateTime.tryParse(json['revealedAt'] as String) : null,
    );
  }
}
