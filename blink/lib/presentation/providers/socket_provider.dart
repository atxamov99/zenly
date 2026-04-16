import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/socket_service.dart';
import 'auth_provider.dart';

final socketServiceProvider = Provider<SocketService>((ref) {
  final service = SocketService(ref.watch(tokenStorageProvider));
  ref.onDispose(service.dispose);
  return service;
});

final socketConnectionProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(socketServiceProvider);
  return service.onConnectionChanged;
});
