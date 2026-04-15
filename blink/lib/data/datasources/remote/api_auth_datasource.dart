import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../local/token_storage.dart';
import 'api_client.dart';

class ApiAuthDatasource {
  final ApiClient _client;
  final TokenStorage _tokenStorage;
  final GoogleSignIn _googleSignIn;

  ApiAuthDatasource({
    required ApiClient client,
    required TokenStorage tokenStorage,
    GoogleSignIn? googleSignIn,
  })  : _client = client,
        _tokenStorage = tokenStorage,
        _googleSignIn = googleSignIn ?? GoogleSignIn(scopes: ['email', 'profile']);

  Dio get _dio => _client.dio;

  Future<String> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      return await _persistAndReturnUid(response.data);
    } on DioException catch (e) {
      throw AuthException(_extractMessage(e, 'Login failed'));
    }
  }

  Future<String> registerWithEmail({
    required String email,
    required String password,
    required String username,
    required String displayName,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: {
          'email': email,
          'password': password,
          'username': username,
          'displayName': displayName,
        },
      );
      return await _persistAndReturnUid(response.data);
    } on DioException catch (e) {
      throw AuthException(_extractMessage(e, 'Registration failed'));
    }
  }

  Future<String> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthException('Google sign-in cancelled');
      }
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        throw const AuthException('Google idToken not available');
      }

      final response = await _dio.post(
        ApiConstants.google,
        data: {'idToken': idToken},
      );
      return await _persistAndReturnUid(response.data);
    } on DioException catch (e) {
      throw AuthException(_extractMessage(e, 'Google sign-in failed'));
    }
  }

  Future<void> signOut() async {
    try {
      await _dio.post(ApiConstants.logout);
    } catch (_) {
      // Server logout failure is non-fatal — local cleanup still happens.
    }
    await _googleSignIn.signOut();
    await _tokenStorage.clear();
  }

  Future<Map<String, dynamic>> getMe() async {
    try {
      final response = await _dio.get(ApiConstants.me);
      return response.data['user'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw AuthException(_extractMessage(e, 'Failed to fetch user'));
    }
  }

  Future<String?> getStoredUid() => _tokenStorage.getUserId();

  Future<bool> hasValidSession() => _tokenStorage.hasToken();

  Future<String> _persistAndReturnUid(dynamic data) async {
    final accessToken = data['accessToken'] as String;
    final refreshToken = data['refreshToken'] as String;
    final user = data['user'] as Map<String, dynamic>;
    final userId = (user['id'] ?? user['_id']).toString();

    await _tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: userId,
    );
    return userId;
  }

  String _extractMessage(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    return fallback;
  }
}
