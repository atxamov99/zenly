import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

import '../core/constants/api_constants.dart';
import '../data/datasources/local/token_storage.dart';

class SocketService {
  final TokenStorage _tokenStorage;
  io.Socket? _socket;

  final _locationController = StreamController<Map<String, dynamic>>.broadcast();
  final _presenceController = StreamController<Map<String, dynamic>>.broadcast();
  final _smartStatusController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();
  final _notificationController =
      StreamController<Map<String, dynamic>>.broadcast();

  SocketService(this._tokenStorage);

  Stream<Map<String, dynamic>> get onLocationChanged =>
      _locationController.stream;
  Stream<Map<String, dynamic>> get onPresenceChanged =>
      _presenceController.stream;
  Stream<Map<String, dynamic>> get onSmartStatusChanged =>
      _smartStatusController.stream;
  Stream<bool> get onConnectionChanged => _connectionController.stream;
  Stream<Map<String, dynamic>> get onNotification =>
      _notificationController.stream;

  bool get isConnected => _socket?.connected ?? false;

  io.Socket get socket {
    return _ensureSocket();
  }

  io.Socket _ensureSocket() {
    final s = _socket;
    if (s != null) return s;
    // Lazy-instantiate socket instance (not yet connected).
    // Token is attached later in connect() via socket.auth.
    final created = io.io(
      ApiConstants.socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(0x7FFFFFFF)
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(10000)
          .build(),
    );
    created
      ..onConnect((_) => _connectionController.add(true))
      ..onDisconnect((_) => _connectionController.add(false))
      ..on('socket:ready', (_) => _connectionController.add(true))
      ..on('friend:location_changed', (data) {
        if (data is Map) {
          _locationController.add(Map<String, dynamic>.from(data));
        }
      })
      ..on('friend:presence_changed', (data) {
        if (data is Map) {
          _presenceController.add(Map<String, dynamic>.from(data));
        }
      })
      ..on('friend:smart_status_changed', (data) {
        if (data is Map) {
          _smartStatusController.add(Map<String, dynamic>.from(data));
        }
      })
      ..on('notification:new', (data) {
        if (data is Map) {
          _notificationController.add(Map<String, dynamic>.from(data));
        }
      });
    _socket = created;
    return created;
  }

  Future<void> connect() async {
    final s = _ensureSocket();
    if (s.connected) return;

    final token = await _tokenStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      throw StateError('No token available for socket connection');
    }

    s.auth = {'token': token};
    s.connect();
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _connectionController.add(false);
  }

  void dispose() {
    disconnect();
    _locationController.close();
    _presenceController.close();
    _smartStatusController.close();
    _connectionController.close();
    _notificationController.close();
  }
}
