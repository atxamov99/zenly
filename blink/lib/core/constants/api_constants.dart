class ApiConstants {
  static const String baseUrl = 'https://aphotic-verbally-nikia.ngrok-free.dev/api';
  static const String socketUrl = 'https://aphotic-verbally-nikia.ngrok-free.dev';

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

  // Location
  static const String locationUpdate = '/location/update';
  static const String visibleFriends = '/location/visible-friends';
  static String shareLocation(String friendId) => '/location/share/$friendId';
  static String unshareLocation(String friendId) => '/location/share/$friendId';
}
