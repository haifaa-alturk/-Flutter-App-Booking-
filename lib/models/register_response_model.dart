import 'user_model.dart';

class RegisterResponseModel {
  final String message;
  final UserModel user;

  RegisterResponseModel({
    required this.message,
    required this.user,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      message: json['message'],
      user: UserModel.fromJson(json['user']),
    );
  }
}
