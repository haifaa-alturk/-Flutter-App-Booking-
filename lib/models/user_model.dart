class UserModel {
  final int id;
  final String phone;
  final String role;
  final String status;
  final String firstName;
  final String lastName;
  final String birthDate;
  final String? userImageUrl;
  final String? idImageUrl;

  UserModel({
    required this.id,
    required this.phone,
    required this.role,
    required this.status,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    this.userImageUrl,
    this.idImageUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
      status: json['status'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      birthDate: json['birth_date'] ?? '',
      userImageUrl: json['user_image_url'],
      idImageUrl: json['id_image_url'],
    );
  }
}