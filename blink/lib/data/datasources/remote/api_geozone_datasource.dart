import 'package:dio/dio.dart';

import '../../../core/errors/exceptions.dart';
import '../../../domain/entities/geozone_entity.dart';
import 'api_client.dart';

class ApiGeozoneDatasource {
  final ApiClient _client;
  ApiGeozoneDatasource(this._client);
  Dio get _dio => _client.dio;

  Future<List<GeozoneEntity>> list() async {
    try {
      final res = await _dio.get('/geozones');
      final list = (res.data['geozones'] as List<dynamic>?) ?? const [];
      return list
          .map((e) => _from(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(_extract(e, 'Failed to fetch geozones'));
    }
  }

  Future<GeozoneEntity> create({
    required String name,
    required String kind,
    required double lat,
    required double lng,
    required double radiusMeters,
    List<String> notifyViewerIds = const [],
  }) async {
    try {
      final res = await _dio.post('/geozones', data: {
        'name': name,
        'kind': kind,
        'lat': lat,
        'lng': lng,
        'radiusMeters': radiusMeters,
        'notifyViewerIds': notifyViewerIds,
      });
      return _from(res.data['geozone'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(_extract(e, 'Failed to create geozone'));
    }
  }

  Future<GeozoneEntity> update({
    required String id,
    String? name,
    String? kind,
    double? lat,
    double? lng,
    double? radiusMeters,
    List<String>? notifyViewerIds,
    bool? isActive,
  }) async {
    try {
      final res = await _dio.patch('/geozones/$id', data: {
        if (name != null) 'name': name,
        if (kind != null) 'kind': kind,
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
        if (radiusMeters != null) 'radiusMeters': radiusMeters,
        if (notifyViewerIds != null) 'notifyViewerIds': notifyViewerIds,
        if (isActive != null) 'isActive': isActive,
      });
      return _from(res.data['geozone'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(_extract(e, 'Failed to update geozone'));
    }
  }

  Future<void> delete(String id) async {
    try {
      await _dio.delete('/geozones/$id');
    } on DioException catch (e) {
      throw ServerException(_extract(e, 'Failed to delete geozone'));
    }
  }

  GeozoneEntity _from(Map<String, dynamic> json) {
    final viewers =
        ((json['notifyViewers'] as List<dynamic>?) ?? const []).map((e) {
      if (e is Map) return (e['_id'] ?? e['id']).toString();
      return e.toString();
    }).toList();
    return GeozoneEntity(
      id: (json['_id'] ?? json['id']).toString(),
      name: (json['name'] ?? '').toString(),
      kind: (json['kind'] ?? 'custom').toString(),
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      radiusMeters: (json['radiusMeters'] as num).toDouble(),
      notifyViewerIds: viewers,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  String _extract(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map<String, dynamic> && data['message'] is String) {
      return data['message'] as String;
    }
    return fallback;
  }
}
