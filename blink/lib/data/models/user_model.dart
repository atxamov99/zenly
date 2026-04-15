import '../../domain/entities/user_entity.dart';

class UserModel {
  final String uid;
  final String displayName;
  final String username;
  final String email;
  final String phone;
  final String photoUrl;
  final String emoji;
  final String statusMessage;
  final bool isOnline;
  final DateTime? lastSeen;
  final bool ghostMode;
  final List<String> ghostFromList;
  final int batteryPercent;
  final bool isCharging;
  final String locationSharingMode;
  final String? fcmToken;
  final DateTime? createdAt;

  const UserModel({
    required this.uid,
    required this.displayName,
    required this.username,
    required this.email,
    required this.phone,
    required this.photoUrl,
    this.emoji = '',
    this.statusMessage = '',
    required this.isOnline,
    this.lastSeen,
    required this.ghostMode,
    this.ghostFromList = const [],
    required this.batteryPercent,
    required this.isCharging,
    required this.locationSharingMode,
    this.fcmToken,
    this.createdAt,
  });

  /// Backend response: `{ id, username, email, displayName, avatarUrl, privacy, presence }`
  factory UserModel.fromApi(Map<String, dynamic> json) {
    final privacy = (json['privacy'] as Map<String, dynamic>?) ?? const {};
    final presence = (json['presence'] as Map<String, dynamic>?) ?? const {};

    return UserModel(
      uid: (json['id'] ?? json['_id'] ?? '').toString(),
      displayName: json['displayName'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      photoUrl: json['avatarUrl'] as String? ?? '',
      emoji: '',
      statusMessage: '',
      isOnline: presence['isOnline'] as bool? ?? false,
      lastSeen: presence['lastSeenAt'] != null
          ? DateTime.tryParse(presence['lastSeenAt'].toString())
          : null,
      ghostMode: privacy['ghostMode'] as bool? ?? false,
      ghostFromList: const [],
      batteryPercent: 100,
      isCharging: false,
      locationSharingMode: privacy['locationVisibility'] as String? ?? 'friends',
      fcmToken: null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toApi() => {
        'displayName': displayName,
        'username': username,
        'avatarUrl': photoUrl,
      };

  UserEntity toEntity() => UserEntity(
        uid: uid,
        displayName: displayName,
        username: username,
        email: email,
        phone: phone,
        photoUrl: photoUrl,
        emoji: emoji,
        statusMessage: statusMessage,
        isOnline: isOnline,
        lastSeen: lastSeen,
        ghostMode: ghostMode,
        ghostFromList: ghostFromList,
        batteryPercent: batteryPercent,
        isCharging: isCharging,
        locationSharingMode: locationSharingMode,
        fcmToken: fcmToken,
      );

  factory UserModel.fromEntity(UserEntity entity) => UserModel(
        uid: entity.uid,
        displayName: entity.displayName,
        username: entity.username,
        email: entity.email,
        phone: entity.phone,
        photoUrl: entity.photoUrl,
        emoji: entity.emoji,
        statusMessage: entity.statusMessage,
        isOnline: entity.isOnline,
        lastSeen: entity.lastSeen,
        ghostMode: entity.ghostMode,
        ghostFromList: entity.ghostFromList,
        batteryPercent: entity.batteryPercent,
        isCharging: entity.isCharging,
        locationSharingMode: entity.locationSharingMode,
        fcmToken: entity.fcmToken,
      );
}
