import 'package:equatable/equatable.dart';

class Login extends Equatable {
  final String? token;
  final String? username;

  const Login({this.token, this.username});

  factory Login.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    String? tok = json['token'] as String?;
    tok ??= json['accessToken'] as String?;
    if (tok == null && data is Map<String, dynamic>) {
      tok = (data['token'] ??
          data['accessToken'] ??
          data['jwt'] ??
          data['jwtToken']) as String?;
    }

    String? name = (json['fullName'] ??
        json['username'] ??
        json['userName'] ??
        json['name']) as String?;
    if (name == null && data is Map<String, dynamic>) {
      name = (data['fullName'] ??
          data['username'] ??
          data['userName'] ??
          data['name']) as String?;
    }

    return Login(token: tok, username: name);
  }

  Map<String, dynamic> toJson() => {
        'token': token,
        'username': username,
      };

  @override
  List<Object?> get props => [token, username];
}
