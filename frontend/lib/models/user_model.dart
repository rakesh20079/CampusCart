class UserModel {
  final int id;
  final String email;
  final String fullName;
  final String? avatarUrl;
  final String? phoneNumber;
  final String? whatsappNumber;
  final String? campusName;
  final String? dormOrHostel;
  final String role;
  final bool verified;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.avatarUrl,
    this.phoneNumber,
    this.whatsappNumber,
    this.campusName,
    this.dormOrHostel,
    required this.role,
    required this.verified,
  });

  bool get isVerifiedStudent => role == 'ROLE_VERIFIED_STUDENT' || verified;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0,
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? 'Student',
      avatarUrl: json['avatarUrl'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      whatsappNumber: json['whatsappNumber'] as String?,
      campusName: json['campusName'] as String?,
      dormOrHostel: json['dormOrHostel'] as String?,
      role: json['role'] as String? ?? 'ROLE_STUDENT',
      verified: json['verified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'avatarUrl': avatarUrl,
      'phoneNumber': phoneNumber,
      'whatsappNumber': whatsappNumber,
      'campusName': campusName,
      'dormOrHostel': dormOrHostel,
      'role': role,
      'verified': verified,
    };
  }
}
