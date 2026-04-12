class UserEntity {
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
  final String locationSharingMode; // "precise" | "approximate" | "off"
  final String? fcmToken;

  const UserEntity({
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
  });

  bool get isGhost => ghostMode;

  UserEntity copyWith({
    String? uid,
    String? displayName,
    String? username,
    String? email,
    String? phone,
    String? photoUrl,
    String? emoji,
    String? statusMessage,
    bool? isOnline,
    DateTime? lastSeen,
    bool? ghostMode,
    List<String>? ghostFromList,
    int? batteryPercent,
    bool? isCharging,
    String? locationSharingMode,
    String? fcmToken,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      emoji: emoji ?? this.emoji,
      statusMessage: statusMessage ?? this.statusMessage,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      ghostMode: ghostMode ?? this.ghostMode,
      ghostFromList: ghostFromList ?? this.ghostFromList,
      batteryPercent: batteryPercent ?? this.batteryPercent,
      isCharging: isCharging ?? this.isCharging,
      locationSharingMode: locationSharingMode ?? this.locationSharingMode,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}
