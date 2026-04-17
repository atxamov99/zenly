class FriendRequestEntity {
  final String requestId;
  final String userId;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final DateTime? createdAt;

  const FriendRequestEntity({
    required this.requestId,
    required this.userId,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.createdAt,
  });

  factory FriendRequestEntity.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? json;
    return FriendRequestEntity(
      requestId: json['requestId']?.toString() ??
          json['_id']?.toString() ??
          json['id']?.toString() ??
          '',
      userId: user['userId']?.toString() ?? user['_id']?.toString() ?? '',
      username: user['username'] as String? ?? '',
      displayName: user['displayName'] as String? ?? '',
      avatarUrl: user['avatarUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}
