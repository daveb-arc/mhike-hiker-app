import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mhike/services/crud/model/hike.dart';
import 'package:mhike/services/crud/model/comment.dart';
import 'package:mhike/services/crud/model/observation.dart';
import 'package:mhike/services/crud/model/picture.dart';
import 'package:mhike/services/crud/model/user.dart' as mhike_user;

class MHikeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------------- USERS ----------------

  Future<void> createUser({
    required String userId,
    required mhike_user.User user,
  }) async {
    await _db.collection('users').doc(userId).set({
      'email': user.email,
      'username': user.username,
      'fullName': user.fullName,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<mhike_user.User?> userById(String userId) {
    return _db.collection('users').doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      final data = doc.data() as Map<String, dynamic>? ?? {};
      return mhike_user.User(
        id: doc.id,
        email: (data['email'] ?? '') as String,
        username: (data['username'] ?? '') as String,
        fullName: (data['fullName'] ?? '') as String,
      );
    });
  }

  // ---------------- HIKES ----------------

  Stream<List<Hike>> get allHikes {
    return _db
        .collection('hikes')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Hike.fromDoc(d)).toList());
  }

  Future<Hike> createHike(Hike hike) async {
    final ref = await _db.collection('hikes').add(hike.toMap());
    return hike.copyWith(id: ref.id);
  }

  // ---------------- COMMENTS ----------------
  // hikes/{hikeId}/comments/{commentId}

  Stream<List<Comment>> commentsForHike(String hikeId) {
    return _db
        .collection('hikes')
        .doc(hikeId)
        .collection('comments')
        // your Comment model writes/reads "dateTime"
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Comment.fromFirestore(doc))
              .toList(),
        );
  }

  Future<void> addComment({
    required String hikeId,
    required Comment comment,
  }) async {
    await _db.collection('hikes').doc(hikeId).collection('comments').add(
          comment.toFirestore(hikeId: hikeId),
        );
  }

  // ---------------- OBSERVATIONS ----------------
  // hikes/{hikeId}/observations/{obsId}

  Stream<List<Observation>> observationsForHike(String hikeId) {
    return _db
        .collection('hikes')
        .doc(hikeId)
        .collection('observations')
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Observation.fromFirestore(doc)).toList());
  }

  Future<void> addObservation({
    required String hikeId,
    required Observation observation,
  }) async {
    await _db
        .collection('hikes')
        .doc(hikeId)
        .collection('observations')
        .add(observation.toFirestore(hikeId: hikeId));
  }

  // ---------------- PICTURES ----------------
  // hikes/{hikeId}/pictures/{picId}

  Stream<List<Picture>> picturesForHike(String hikeId) {
    return _db
        .collection('hikes')
        .doc(hikeId)
        .collection('pictures')
        .orderBy('time', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Picture.fromDoc(doc)).toList());
  }

  Future<void> addPicture({
    required String hikeId,
    required Picture picture,
  }) async {
    await _db
        .collection('hikes')
        .doc(hikeId)
        .collection('pictures')
        .add(picture.toMap());
  }
}
