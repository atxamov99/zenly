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
  static const String profilePrivacy = '/profile/privacy';

  // Location
  static const String locationUpdate = '/location/update';
  static const String visibleFriends = '/location/visible-friends';
  static String shareLocation(String friendId) => '/location/share/$friendId';
  static String unshareLocation(String friendId) => '/location/share/$friendId';

  // Friends
  static const String friends = '/friends';
  static const String friendsSearch = '/friends/search';
  static const String friendsRequests = '/friends/requests';
  static const String friendRequest = '/friends/request';
  static String friendRespond(String requestId) =>
      '/friends/$requestId/respond';
  static String friendCancelRequest(String requestId) =>
      '/friends/request/$requestId';
  static String unfriend(String friendId) => '/friends/$friendId';

  // Blocks
  static const String blocks = '/blocks';
  static String blockUser(String userId) => '/blocks/$userId';
  static String unblockUser(String userId) => '/blocks/$userId';

  // Chat
  static const String chats = '/chats';
  static String chatMessages(String friendId) => '/chats/$friendId/messages';
  static String chatRead(String friendId) => '/chats/$friendId/read';
  static String editMessage(String messageId) => '/chats/messages/$messageId';
  static String deleteMessage(String messageId) => '/chats/messages/$messageId';
}
