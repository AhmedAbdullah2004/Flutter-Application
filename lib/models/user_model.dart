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
      id: json['id']?.toString() ??
          json['userId']?.toString() ??
          '',

      name: json['fullName']?.toString() ??
          json['name']?.toString() ??
          json['unique_name']?.toString() ??
          'مستخدم',

      email: json['email']?.toString() ?? '',

      phone: json['phoneNumber']?.toString() ??
          json['phone']?.toString() ??
          '',

      kycLevel: json['kycLevel']?.toString() ?? 'Basic',

      status: json['status']?.toString() ?? 'Active',
    );
  }
}