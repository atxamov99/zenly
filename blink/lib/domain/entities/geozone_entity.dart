class GeozoneEntity {
  final String id;
  final String name;
  final String kind; // home | study | work | custom
  final double lat;
  final double lng;
  final double radiusMeters;
  final List<String> notifyViewerIds;
  final bool isActive;

  const GeozoneEntity({
    required this.id,
    required this.name,
    required this.kind,
    required this.lat,
    required this.lng,
    required this.radiusMeters,
    this.notifyViewerIds = const [],
    this.isActive = true,
  });

  String get emoji {
    switch (kind) {
      case 'home':
        return '🏠';
      case 'study':
        return '📚';
      case 'work':
        return '💼';
      default:
        return '📍';
    }
  }
}
