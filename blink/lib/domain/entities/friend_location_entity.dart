class FriendLocationEntity {
  final String friendId;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final double lat;
  final double lng;
  final double? accuracy;
  final bool isOnline;
  final String smartStatus;
  final int? batteryPercent;
  final DateTime? lastSeenAt;

  const FriendLocationEntity({
    required this.friendId,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    required this.lat,
    required this.lng,
    this.accuracy,
    required this.isOnline,
    required this.smartStatus,
    this.batteryPercent,
    this.lastSeenAt,
  });

  factory FriendLocationEntity.fromJson(Map<String, dynamic> json) {
    return FriendLocationEntity(
      friendId: json['friendId'].toString(),
      username: json['username'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      isOnline: json['isOnline'] as bool? ?? false,
      smartStatus: json['smartStatus'] as String? ?? 'offline',
      batteryPercent: json['batteryPercent'] as int?,
      lastSeenAt: json['lastSeenAt'] != null
          ? DateTime.tryParse(json['lastSeenAt'] as String)
          : null,
    );
  }

  FriendLocationEntity copyWith({
    double? lat,
    double? lng,
    double? accuracy,
    bool? isOnline,
    String? smartStatus,
    int? batteryPercent,
    DateTime? lastSeenAt,
  }) {
    return FriendLocationEntity(
      friendId: friendId,
      username: username,
      displayName: displayName,
      avatarUrl: avatarUrl,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      accuracy: accuracy ?? this.accuracy,
      isOnline: isOnline ?? this.isOnline,
      smartStatus: smartStatus ?? this.smartStatus,
      batteryPercent: batteryPercent ?? this.batteryPercent,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
    );
  }
}
