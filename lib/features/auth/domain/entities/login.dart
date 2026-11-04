import 'package:equatable/equatable.dart';

class Login extends Equatable {
  final String? token;
  final String? username;

  const Login({this.token, this.username});

  /// Parses the login response. Accepts the token and display name either at
  /// the top level or nested under `data`. Values of unexpected types are
  /// ignored instead of throwing.
  factory Login.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final nested =
        data is Map<String, dynamic> ? data : const <String, dynamic>{};

    final token = _firstString([
      json['token'],
      json['accessToken'],
      nested['token'],
      nested['accessToken'],
      nested['jwt'],
      nested['jwtToken'],
    ]);
    final name = _firstString([
      json['fullName'],
      json['username'],
      json['userName'],
      json['name'],
      nested['fullName'],
      nested['username'],
      nested['userName'],
      nested['name'],
    ]);

    return Login(token: token, username: name);
  }

  static String? _firstString(List<Object?> candidates) {
    for (final candidate in candidates) {
      if (candidate is String && candidate.trim().isNotEmpty) {
        return candidate.trim();
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
        'token': token,
        'username': username,
      };

  @override
  List<Object?> get props => [token, username];
}
