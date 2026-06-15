class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String kycLevel;
  final String status;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.kycLevel,
    required this.status,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['userId'] ?? '',
      name: json['name'] ?? json['unique_name'] ?? 'مستخدم',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      kycLevel: json['kycLevel'] ?? 'Basic',
      status: json['status'] ?? 'Active',
    );
  }
}