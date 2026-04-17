class FriendEntity {
  final String userId;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final bool isOnline;
  final String smartStatus;
  final DateTime? lastSeenAt;

  const FriendEntity({
    required this.userId,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    required this.isOnline,
    required this.smartStatus,
    this.lastSeenAt,
  });

  factory FriendEntity.fromJson(Map<String, dynamic> json) {
    return FriendEntity(
      userId: json['userId']?.toString() ?? json['_id']?.toString() ?? '',
      username: json['username'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      isOnline: json['isOnline'] as bool? ?? false,
      smartStatus: json['smartStatus'] as String? ?? 'offline',
      lastSeenAt: json['lastSeenAt'] != null
          ? DateTime.tryParse(json['lastSeenAt'].toString())
          : null,
    );
  }
}
