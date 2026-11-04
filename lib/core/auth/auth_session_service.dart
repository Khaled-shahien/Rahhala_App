import 'package:rahhala_app/core/utils/token_storage.dart';
import 'package:rahhala_app/core/utils/user_session.dart';

class CurrentUserBasicInfo {
  const CurrentUserBasicInfo({
    this.username,
    this.email,
    this.fullName,
    this.profileImageUrl,
  });

  final String? username;
  final String? email;
  final String? fullName;
  final String? profileImageUrl;

  bool get isEmpty =>
      username == null &&
      email == null &&
      fullName == null &&
      profileImageUrl == null;
}

class AuthSessionService {
  AuthSessionService({
    required TokenStorage tokenStorage,
    required UserSession userSession,
  })  : _tokenStorage = tokenStorage,
        _userSession = userSession;

  final TokenStorage _tokenStorage;
  final UserSession _userSession;

  bool get hasToken => _tokenStorage.hasToken;
  String? get token => _tokenStorage.token;
  String? get username => _tokenStorage.username;
  String? get email => _tokenStorage.email ?? _userSession.email;
  String? get fullName => _tokenStorage.fullName ?? _userSession.displayName;
  String? get profileImageUrl =>
      _tokenStorage.profileImageUrl ?? _userSession.avatarUrl;
  String get displayName => _tokenStorage.displayName;

  CurrentUserBasicInfo get currentUser => CurrentUserBasicInfo(
        username: username,
        email: email,
        fullName: fullName,
        profileImageUrl: profileImageUrl,
      );

  Future<void> saveSession({
    String? token,
    String? username,
    String? email,
    String? fullName,
    String? profileImageUrl,
  }) async {
    final trimmedToken = token?.trim();
    final trimmedUsername = username?.trim();
    final normalizedEmail = email?.trim().toLowerCase();
    final trimmedFullName = fullName?.trim();
    final trimmedProfileImageUrl = profileImageUrl?.trim();

    if (trimmedToken != null && trimmedToken.isNotEmpty) {
      await _tokenStorage.setToken(trimmedToken);
    }
    if (trimmedUsername != null && trimmedUsername.isNotEmpty) {
      await _tokenStorage.setUsername(trimmedUsername);
    }
    if (normalizedEmail != null && normalizedEmail.isNotEmpty) {
      await _tokenStorage.setEmail(normalizedEmail);
    }
    if (trimmedFullName != null && trimmedFullName.isNotEmpty) {
      await _tokenStorage.setFullName(trimmedFullName);
    }
    if (trimmedProfileImageUrl != null && trimmedProfileImageUrl.isNotEmpty) {
      await _tokenStorage.setProfileImageUrl(trimmedProfileImageUrl);
    }

    final effectiveEmail = normalizedEmail ?? _tokenStorage.email;
    final effectiveDisplayName = trimmedFullName ?? _tokenStorage.fullName;
    if (effectiveEmail != null && effectiveEmail.isNotEmpty) {
      _userSession.setFromLogin(
        email: effectiveEmail,
        displayName: effectiveDisplayName,
      );
    }
    if (trimmedProfileImageUrl != null && trimmedProfileImageUrl.isNotEmpty) {
      _userSession.avatarUrl = trimmedProfileImageUrl;
    }
  }

  Future<void> clearSession() async {
    await _tokenStorage.clearAll();
    _userSession.clear();
  }

  Future<void> logout() => clearSession();
}
