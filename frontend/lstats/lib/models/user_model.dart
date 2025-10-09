import 'dart:convert';

class UserModel {
  final String id;
  final String username;
  final String email;
  final String collegename;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.collegename,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["id"].toString(),
      username: json["username"],
      email: json["email"],
      collegename: json['collegename']??"other"
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "username": username,
      "email": email,
      "collegename":collegename
    };
  }
}
