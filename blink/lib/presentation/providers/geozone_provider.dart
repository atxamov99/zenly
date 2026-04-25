import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/api_geozone_datasource.dart';
import '../../domain/entities/geozone_entity.dart';
import 'auth_provider.dart';

final apiGeozoneDatasourceProvider = Provider<ApiGeozoneDatasource>((ref) {
  return ApiGeozoneDatasource(ref.watch(apiClientProvider));
});

class GeozonesNotifier extends AsyncNotifier<List<GeozoneEntity>> {
  @override
  Future<List<GeozoneEntity>> build() async {
    return ref.read(apiGeozoneDatasourceProvider).list();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(apiGeozoneDatasourceProvider).list());
  }

  Future<GeozoneEntity> create({
    required String name,
    required String kind,
    required double lat,
    required double lng,
    required double radiusMeters,
    List<String> notifyViewerIds = const [],
  }) async {
    final created =
        await ref.read(apiGeozoneDatasourceProvider).create(
              name: name,
              kind: kind,
              lat: lat,
              lng: lng,
              radiusMeters: radiusMeters,
              notifyViewerIds: notifyViewerIds,
            );
    final current = state.value ?? const [];
    state = AsyncData([created, ...current]);
    return created;
  }

  Future<void> delete(String id) async {
    await ref.read(apiGeozoneDatasourceProvider).delete(id);
    final current = state.value ?? const [];
    state = AsyncData(current.where((g) => g.id != id).toList());
  }
}

final geozonesProvider =
    AsyncNotifierProvider<GeozonesNotifier, List<GeozoneEntity>>(
        GeozonesNotifier.new);
