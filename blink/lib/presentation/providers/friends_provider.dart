import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/api_block_datasource.dart';
import '../../data/datasources/remote/api_friends_datasource.dart';
import '../../domain/entities/friend_entity.dart';
import '../../domain/entities/friend_request_entity.dart';
import 'auth_provider.dart';
import 'socket_provider.dart';

final apiFriendsDatasourceProvider = Provider<ApiFriendsDatasource>((ref) {
  return ApiFriendsDatasource(ref.watch(apiClientProvider));
});

final apiBlockDatasourceProvider = Provider<ApiBlockDatasource>((ref) {
  return ApiBlockDatasource(ref.watch(apiClientProvider));
});

class FriendsNotifier extends AsyncNotifier<List<FriendEntity>> {
  StreamSubscription<Map<String, dynamic>>? _notifSub;

  @override
  Future<List<FriendEntity>> build() async {
    ref.onDispose(() {
      _notifSub?.cancel();
    });

    final socket = ref.read(socketServiceProvider);
    _notifSub = socket.onNotification.listen(_handleNotification);

    final ds = ref.read(apiFriendsDatasourceProvider);
    return ds.getFriends();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final ds = ref.read(apiFriendsDatasourceProvider);
      return ds.getFriends();
    });
  }

  Future<void> unfriend(String friendId) async {
    await ref.read(apiFriendsDatasourceProvider).unfriend(friendId);
    final current = state.value ?? [];
    state = AsyncData(current.where((f) => f.userId != friendId).toList());
  }

  void _handleNotification(Map<String, dynamic> data) {
    final notif = data['notification'] as Map<String, dynamic>?;
    if (notif == null) return;
    final type = notif['type']?.toString();
    if (type == 'friend_request_accepted' || type == 'friend_removed') {
      refresh();
      ref.read(friendRequestsProvider.notifier).refresh();
    } else if (type == 'friend_request_received') {
      ref.read(friendRequestsProvider.notifier).refresh();
    }
  }
}

final friendsProvider =
    AsyncNotifierProvider<FriendsNotifier, List<FriendEntity>>(
  FriendsNotifier.new,
);

class FriendRequestsState {
  final List<FriendRequestEntity> incoming;
  final List<FriendRequestEntity> outgoing;

  const FriendRequestsState({this.incoming = const [], this.outgoing = const []});
}

class FriendRequestsNotifier extends AsyncNotifier<FriendRequestsState> {
  @override
  Future<FriendRequestsState> build() async {
    final ds = ref.read(apiFriendsDatasourceProvider);
    final result = await ds.getRequests();
    return FriendRequestsState(
      incoming: result.incoming,
      outgoing: result.outgoing,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final ds = ref.read(apiFriendsDatasourceProvider);
      final result = await ds.getRequests();
      return FriendRequestsState(
        incoming: result.incoming,
        outgoing: result.outgoing,
      );
    });
  }

  Future<void> sendRequest(String username) async {
    await ref.read(apiFriendsDatasourceProvider).sendRequest(username);
    await refresh();
  }

  Future<void> respond(String requestId, {required bool accept}) async {
    await ref
        .read(apiFriendsDatasourceProvider)
        .respondRequest(requestId, accept: accept);
    await refresh();
    if (accept) {
      ref.invalidate(friendsProvider);
    }
  }

  Future<void> cancel(String requestId) async {
    await ref.read(apiFriendsDatasourceProvider).cancelRequest(requestId);
    await refresh();
  }
}

final friendRequestsProvider =
    AsyncNotifierProvider<FriendRequestsNotifier, FriendRequestsState>(
  FriendRequestsNotifier.new,
);

final incomingRequestCountProvider = Provider<int>((ref) {
  final reqs = ref.watch(friendRequestsProvider).value;
  return reqs?.incoming.length ?? 0;
});

class FriendSearchNotifier extends AsyncNotifier<List<FriendEntity>> {
  @override
  Future<List<FriendEntity>> build() async => [];

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const AsyncData([]);
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      return ref.read(apiFriendsDatasourceProvider).search(query);
    });
  }
}

final friendSearchProvider =
    AsyncNotifierProvider<FriendSearchNotifier, List<FriendEntity>>(
  FriendSearchNotifier.new,
);
