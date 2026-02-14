class UserSession {
  String? displayName;
  String? email;
  String? avatarUrl;

  void setFromRegister(
      {required String fullName, required String email, String? avatarUrl}) {
    displayName = fullName.trim();
    this.email = email.trim();
    this.avatarUrl = avatarUrl;
  }

  void setFromLogin({required String email, String? displayName}) {
    this.email = email.trim();
    
    this.displayName = (displayName?.trim().isNotEmpty ?? false)
        ? displayName!.trim()
        : _fallbackNameFromEmail(email);
  }

  String get hiName {
    if (displayName != null && displayName!.trim().isNotEmpty) {
      return displayName!;
    }
    if (email != null) return _fallbackNameFromEmail(email!);
    return 'there';
  }

  String _fallbackNameFromEmail(String email) {
    final local = email.split('@').first;
    if (local.isEmpty) return 'there';
    return local[0].toUpperCase() + local.substring(1);
  }
}
