import 'package:cloud_firestore/cloud_firestore.dart';
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

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      displayName: json['displayName'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      photoUrl: json['photoUrl'] as String? ?? '',
      emoji: json['emoji'] as String? ?? '',
      statusMessage: json['statusMessage'] as String? ?? '',
      isOnline: json['isOnline'] as bool? ?? false,
      lastSeen: json['lastSeen'] is Timestamp
          ? (json['lastSeen'] as Timestamp).toDate()
          : null,
      ghostMode: json['ghostMode'] as bool? ?? false,
      ghostFromList: List<String>.from(json['ghostFromList'] ?? []),
      batteryPercent: json['batteryPercent'] as int? ?? 100,
      isCharging: json['isCharging'] as bool? ?? false,
      locationSharingMode: json['locationSharingMode'] as String? ?? 'precise',
      fcmToken: json['fcmToken'] as String?,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    return UserModel.fromJson(doc.data() as Map<String, dynamic>);
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'displayName': displayName,
        'username': username,
        'email': email,
        'phone': phone,
        'photoUrl': photoUrl,
        'emoji': emoji,
        'statusMessage': statusMessage,
        'isOnline': isOnline,
        'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
        'ghostMode': ghostMode,
        'ghostFromList': ghostFromList,
        'batteryPercent': batteryPercent,
        'isCharging': isCharging,
        'locationSharingMode': locationSharingMode,
        'fcmToken': fcmToken,
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
