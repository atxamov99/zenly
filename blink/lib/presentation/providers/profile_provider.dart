import 'package:flutter_riverpod/flutter_riverpod.dart';

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
