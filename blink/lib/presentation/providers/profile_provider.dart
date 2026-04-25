import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_constants.dart';
import '../../data/datasources/remote/api_profile_datasource.dart';
import 'auth_provider.dart';

final apiProfileDatasourceProvider = Provider<ApiProfileDatasource>((ref) {
  return ApiProfileDatasource(ref.watch(apiClientProvider));
});

class GhostModeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final storage = ref.read(tokenStorageProvider);
    return storage.getGhostMode();
  }

  Future<void> toggle(bool value) async {
    final previous = state.value ?? false;
    state = AsyncData(value);
    try {
      await ref.read(apiProfileDatasourceProvider).setGhostMode(value);
      await ref.read(tokenStorageProvider).setGhostMode(value);
    } catch (e, st) {
      state = AsyncData(previous);
      state = AsyncError(e, st);
    }
  }
}

final ghostModeProvider =
    AsyncNotifierProvider<GhostModeNotifier, bool>(GhostModeNotifier.new);

/// Privacy state — backed by `user.privacy` from the server.
/// Server enum: friends | circles | nobody.
class PrivacyState {
  final String locationVisibility;
  final String lastSeenVisibility;
  final String batteryVisibility;

  const PrivacyState({
    required this.locationVisibility,
    required this.lastSeenVisibility,
    required this.batteryVisibility,
  });

  PrivacyState copyWith({
    String? locationVisibility,
    String? lastSeenVisibility,
    String? batteryVisibility,
  }) =>
      PrivacyState(
        locationVisibility: locationVisibility ?? this.locationVisibility,
        lastSeenVisibility: lastSeenVisibility ?? this.lastSeenVisibility,
        batteryVisibility: batteryVisibility ?? this.batteryVisibility,
      );
}

class PrivacyNotifier extends AsyncNotifier<PrivacyState> {
  @override
  Future<PrivacyState> build() async {
    final res = await ref.read(apiClientProvider).dio.get(ApiConstants.me);
    final user = (res.data['user'] as Map<String, dynamic>?) ??
        (res.data as Map<String, dynamic>);
    final privacy = (user['privacy'] as Map<String, dynamic>?) ?? const {};
    return PrivacyState(
      locationVisibility:
          (privacy['locationVisibility'] as String?) ?? 'friends',
      lastSeenVisibility:
          (privacy['lastSeenVisibility'] as String?) ?? 'friends',
      batteryVisibility:
          (privacy['batteryVisibility'] as String?) ?? 'friends',
    );
  }

  Future<void> setLocationVisibility(String value) =>
      _patch(locationVisibility: value);

  Future<void> setBatteryVisibility(String value) =>
      _patch(batteryVisibility: value);

  Future<void> setLastSeenVisibility(String value) =>
      _patch(lastSeenVisibility: value);

  Future<void> _patch({
    String? locationVisibility,
    String? lastSeenVisibility,
    String? batteryVisibility,
  }) async {
    final previous = state.value;
    if (previous == null) return;
    state = AsyncData(previous.copyWith(
      locationVisibility: locationVisibility,
      lastSeenVisibility: lastSeenVisibility,
      batteryVisibility: batteryVisibility,
    ));
    try {
      await ref.read(apiProfileDatasourceProvider).updatePrivacy(
            locationVisibility: locationVisibility,
            lastSeenVisibility: lastSeenVisibility,
            batteryVisibility: batteryVisibility,
          );
    } catch (e, st) {
      state = AsyncData(previous);
      state = AsyncError(e, st);
    }
  }
}

final privacyProvider =
    AsyncNotifierProvider<PrivacyNotifier, PrivacyState>(PrivacyNotifier.new);
