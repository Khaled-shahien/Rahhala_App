import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  final SharedPreferences _prefs;

  static const String _tokenKey = 'auth_token';
  static const String _usernameKey = 'username';
  static const String _emailKey = 'email';
  static const String _fullNameKey = 'full_name';
  static const String _profileImageUrlKey = 'profile_image_url';

  TokenStorage(this._prefs);

  Future<void> setToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  String? get token => _prefs.getString(_tokenKey);

  bool get hasToken {
    final token = _prefs.getString(_tokenKey);
    return token != null && token.isNotEmpty;
  }

  Future<void> setUsername(String username) async {
    await _prefs.setString(_usernameKey, username);
  }

  String? get username => _prefs.getString(_usernameKey);

  Future<void> setEmail(String email) async {
    await _prefs.setString(_emailKey, email);
  }

  String? get email => _prefs.getString(_emailKey);

  Future<void> setFullName(String fullName) async {
    await _prefs.setString(_fullNameKey, fullName);
  }

  String? get fullName => _prefs.getString(_fullNameKey);

  Future<void> setProfileImageUrl(String imageUrl) async {
    await _prefs.setString(_profileImageUrlKey, imageUrl);
  }

  String? get profileImageUrl => _prefs.getString(_profileImageUrlKey);

  Future<void> setBasicInfo({
    required String fullName,
    required String email,
  }) async {
    await setFullName(fullName);
    await setEmail(email);
  }

  String get displayName {
    final name = _prefs.getString(_fullNameKey);
    if (name != null && name.isNotEmpty) {
      return name;
    }

    final uname = _prefs.getString(_usernameKey);
    if (uname != null && uname.isNotEmpty) {
      return uname;
    }

    final mail = _prefs.getString(_emailKey);
    if (mail != null && mail.isNotEmpty) {
      return mail.split('@').first;
    }

    return 'User';
  }

  Future<void> clearToken() async {
    await _prefs.remove(_tokenKey);
  }

  Future<void> clearUsername() async {
    await _prefs.remove(_usernameKey);
  }

  Future<void> clearEmail() async {
    await _prefs.remove(_emailKey);
  }

  Future<void> clearFullName() async {
    await _prefs.remove(_fullNameKey);
  }

  Future<void> clearProfileImageUrl() async {
    await _prefs.remove(_profileImageUrlKey);
  }

  Future<void> clearAll() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_usernameKey);
    await _prefs.remove(_emailKey);
    await _prefs.remove(_fullNameKey);
    await _prefs.remove(_profileImageUrlKey);
  }

  Future<void> clear() async {
    await clearAll();
  }

  void printAllData() {
    print('=== TokenStorage Data ===');
    print(
        'Token: ${token != null ? "***${token!.substring(token!.length - 10)}" : "null"}');
    print('Username: $username');
    print('Email: $email');
    print('Full Name: $fullName');
    print('Profile Image URL: $profileImageUrl');
    print('Display Name: $displayName');
    print('========================');
  }
}
