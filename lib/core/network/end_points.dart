class EndPoints {
  static const String baseUrl = 'https://rahhallaweb2026.runasp.net';

  static const String login = '/api/Auth/Login';
  static const String register = '/api/Auth/register';
  static const String forgotPassword = '/api/Auth/forgot-password';
  static const String verifyOtp = '/api/Auth/verify-otp';
  static const String resetPassword = '/api/Auth/reset-password';

  static const String userDetails = '/api/User/GetDetails';
  static const String editProfile = '/api/User/Edit-Profile';
  static const String deleteProfile = '/api/User/DeleteProfile';
  static const String changePassword = '/api/User/change_password';
  static const String editPhoto = '/api/User/edit_photo';

  static const String askGemini = '/api/gemini/Ask_Gemini';
}

class ApiKey {
  static String token = 'token';
  static String email = 'email';
  static String password = 'password';
  static String error = 'error';
  static String message = 'message';
  static String Message = 'Message';
  static String detail = 'detail';
  static String id = 'id';
  static String msg = 'msg';
  static String status = 'status';
  static String data = 'data';
  static String result = 'result';
}
