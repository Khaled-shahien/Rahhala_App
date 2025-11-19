class AppValidators {
  AppValidators._();

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Invalid email format';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (value.trim().length < 10) {
      return 'Invalid phone number';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) {
      return 'Password is required';
    }
    if (v.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(v)) {
      return 'Password must include at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(v)) {
      return 'Password must include at least one lowercase letter';
    }
    if (!RegExp(r'\d').hasMatch(v)) {
      return 'Password must include at least one number';
    }
    
    if (!RegExp(r'[^A-Za-z0-9\s]').hasMatch(v)) {
      return 'Password must include at least one special character';
    }
    return null;
  }

  static String? validateLoginPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? validateDropdown(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please select a $fieldName';
    }
    return null;
  }
}
