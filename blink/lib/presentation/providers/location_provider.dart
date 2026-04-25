import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../data/datasources/remote/api_location_datasource.dart';
import '../../domain/entities/friend_location_entity.dart';
import '../../services/location_service.dart';
import 'auth_provider.dart';
import 'socket_provider.dart';

final locationServiceProvider = Provider<LocationService>((_) => LocationService());

final apiLocationDatasourceProvider = Provider<ApiLocationDatasource>((ref) {
  return ApiLocationDatasource(ref.watch(apiClientProvider));
});

class FriendsLocationNotifier
    extends AsyncNotifier<Map<String, FriendLocationEntity>> {
  StreamSubscription<Map<String, dynamic>>? _locationSub;
  StreamSubscription<Map<String, dynamic>>? _smartStatusSub;
  StreamSubscription<Map<String, dynamic>>? _presenceSub;
  StreamSubscription<Map<String, dynamic>>? _batterySub;

  @override
  Future<Map<String, FriendLocationEntity>> build() async {
    ref.onDispose(() {
      _locationSub?.cancel();
      _smartStatusSub?.cancel();
      _presenceSub?.cancel();
      _batterySub?.cancel();
    });

    final socket = ref.read(socketServiceProvider);
    _locationSub = socket.onLocationChanged.listen(_handleLocationEvent);
    _smartStatusSub = socket.onSmartStatusChanged.listen(_handleSmartStatusEvent);
    _presenceSub = socket.onPresenceChanged.listen(_handlePresenceEvent);
    _batterySub = socket.onBatteryChanged.listen(_handleBatteryEvent);

    final ds = ref.read(apiLocationDatasourceProvider);
    final friends = await ds.getVisibleFriends();
    return {for (final f in friends) f.friendId: f};
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final ds = ref.read(apiLocationDatasourceProvider);
      final friends = await ds.getVisibleFriends();
      return {for (final f in friends) f.friendId: f};
    });
  }

  void _handleLocationEvent(Map<String, dynamic> data) {
    final friendId = data['friendId']?.toString();
    if (friendId == null) return;
    final current = state.value;
    if (current == null) return;
    final friend = current[friendId];
    if (friend == null) return;

    final updated = friend.copyWith(
      lat: (data['lat'] as num).toDouble(),
      lng: (data['lng'] as num).toDouble(),
      accuracy: (data['accuracy'] as num?)?.toDouble(),
      lastSeenAt: data['lastSeenAt'] != null
          ? DateTime.tryParse(data['lastSeenAt'].toString())
          : null,
    );
    state = AsyncData({...current, friendId: updated});
  }

  void _handleSmartStatusEvent(Map<String, dynamic> data) {
    final friendId = data['friendId']?.toString();
    if (friendId == null) return;
    final current = state.value;
    if (current == null) return;
    final friend = current[friendId];
    if (friend == null) return;

    final updated = friend.copyWith(
      smartStatus: data['smartStatus']?.toString() ?? friend.smartStatus,
    );
    state = AsyncData({...current, friendId: updated});
  }

  void _handlePresenceEvent(Map<String, dynamic> data) {
    final friendId = data['friendId']?.toString();
    if (friendId == null) return;
    final current = state.value;
    if (current == null) return;
    final friend = current[friendId];
    if (friend == null) return;

    final updated = friend.copyWith(
      isOnline: data['isOnline'] as bool? ?? friend.isOnline,
      lastSeenAt: data['lastSeenAt'] != null
          ? DateTime.tryParse(data['lastSeenAt'].toString())
          : friend.lastSeenAt,
    );
    state = AsyncData({...current, friendId: updated});
  }

  void _handleBatteryEvent(Map<String, dynamic> data) {
    final friendId = data['friendId']?.toString();
    if (friendId == null) return;
    final current = state.value;
    if (current == null) return;
    final friend = current[friendId];
    if (friend == null) return;

    final updated = friend.copyWith(
      batteryPercent: (data['batteryPercent'] as num?)?.toInt(),
    );
    state = AsyncData({...current, friendId: updated});
  }
}

final friendsLocationProvider = AsyncNotifierProvider<FriendsLocationNotifier,
    Map<String, FriendLocationEntity>>(FriendsLocationNotifier.new);

final ownLocationProvider = StateProvider<LatLng?>((_) => null);
