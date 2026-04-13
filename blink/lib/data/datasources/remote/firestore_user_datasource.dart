import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/user_model.dart';

class FirestoreUserDatasource {
  final FirebaseFirestore _firestore;

  FirestoreUserDatasource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _users => _firestore.collection('users');

  Future<void> createUser(UserModel user) async {
    try {
      await _users.doc(user.uid).set({
        ...user.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<UserModel> getUserById(String uid) async {
    try {
      final doc = await _users.doc(uid).get();
      if (!doc.exists) throw ServerException('User not found: $uid');
      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<void> updateUser(String uid, Map<String, dynamic> fields) async {
    try {
      await _users.doc(uid).update(fields);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<bool> isUsernameAvailable(String username) async {
    final query = await _users
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    return query.docs.isEmpty;
  }

  Future<void> deleteUser(String uid) async {
    await _users.doc(uid).delete();
  }

  Stream<UserModel> watchUser(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists) throw ServerException('User not found: $uid');
      return UserModel.fromFirestore(doc);
    });
  }
}
