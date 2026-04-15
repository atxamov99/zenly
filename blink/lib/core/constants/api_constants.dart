class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:4000/api';
  static const String socketUrl = 'http://10.0.2.2:4000';

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String google = '/auth/google';
  static const String refresh = '/auth/refresh';
  static const String me = '/auth/me';
  static const String logout = '/auth/logout';

  // Profile
  static const String profile = '/profile';
  static const String avatar = '/profile/avatar';
}
