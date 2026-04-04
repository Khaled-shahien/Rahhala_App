import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _legacyPrefs;
  final Map<String, String> _cache = <String, String>{};
  bool _initialized = false;

  static const String _tokenKey = 'auth_token';
  static const String _usernameKey = 'username';
  static const String _emailKey = 'email';
  static const String _fullNameKey = 'full_name';
  static const String _profileImageUrlKey = 'profile_image_url';

  TokenStorage({
    required FlutterSecureStorage secureStorage,
    required SharedPreferences legacyPrefs,
  })  : _secureStorage = secureStorage,
        _legacyPrefs = legacyPrefs;

  static const List<String> _allKeys = <String>[
    _tokenKey,
    _usernameKey,
    _emailKey,
    _fullNameKey,
    _profileImageUrlKey,
  ];

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    for (final key in _allKeys) {
      final secureValue = await _secureStorage.read(key: key);
      if (secureValue != null && secureValue.isNotEmpty) {
        _cache[key] = secureValue;
        continue;
      }

      final legacyValue = _legacyPrefs.getString(key);
      if (legacyValue != null && legacyValue.isNotEmpty) {
        await _secureStorage.write(key: key, value: legacyValue);
        await _legacyPrefs.remove(key);
        _cache[key] = legacyValue;
      }
    }

    _initialized = true;
  }

  Future<void> _writeValue(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
    _cache[key] = value;
  }

  Future<void> _clearValue(String key) async {
    await _secureStorage.delete(key: key);
    await _legacyPrefs.remove(key);
    _cache.remove(key);
  }

  Future<void> setToken(String token) async {
    await _writeValue(_tokenKey, token);
  }

  String? get token => _cache[_tokenKey];

  bool get hasToken => (token?.isNotEmpty ?? false);

  Future<void> setUsername(String username) async {
    await _writeValue(_usernameKey, username);
  }

  String? get username => _cache[_usernameKey];

  Future<void> setEmail(String email) async {
    await _writeValue(_emailKey, email);
  }

  String? get email => _cache[_emailKey];

  Future<void> setFullName(String fullName) async {
    await _writeValue(_fullNameKey, fullName);
  }

  String? get fullName => _cache[_fullNameKey];

  Future<void> setProfileImageUrl(String imageUrl) async {
    await _writeValue(_profileImageUrlKey, imageUrl);
  }

  String? get profileImageUrl => _cache[_profileImageUrlKey];

  Future<void> setBasicInfo({
    required String fullName,
    required String email,
  }) async {
    await setFullName(fullName);
    await setEmail(email);
  }

  String get displayName {
    final name = _cache[_fullNameKey];
    if (name != null && name.isNotEmpty) {
      return name;
    }

    final uname = _cache[_usernameKey];
    if (uname != null && uname.isNotEmpty) {
      return uname;
    }

    final mail = _cache[_emailKey];
    if (mail != null && mail.isNotEmpty) {
      return mail.split('@').first;
    }

    return 'User';
  }

  Future<void> clearToken() async {
    await _clearValue(_tokenKey);
  }

  Future<void> clearUsername() async {
    await _clearValue(_usernameKey);
  }

  Future<void> clearEmail() async {
    await _clearValue(_emailKey);
  }

  Future<void> clearFullName() async {
    await _clearValue(_fullNameKey);
  }

  Future<void> clearProfileImageUrl() async {
    await _clearValue(_profileImageUrlKey);
  }

  Future<void> clearAll() async {
    for (final key in _allKeys) {
      await _clearValue(key);
    }
  }

  Future<void> clear() async {
    await clearAll();
  }
}
