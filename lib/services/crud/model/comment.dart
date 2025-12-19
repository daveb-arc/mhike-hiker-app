import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String? id;
  final String hikeId;
  final String userId;
  final String userEmail;
  final double rating;
  final String text;
  final DateTime dateTime;

  Comment({
    this.id,
    required this.hikeId,
    required this.userId,
    required this.userEmail,
    required this.rating,
    required this.text,
    required this.dateTime,
  });

  factory Comment.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final ts = data['dateTime'];
    final dt = ts is Timestamp ? ts.toDate() : DateTime.now();

    final ratingRaw = data['rating'];
    final rating = ratingRaw is num ? ratingRaw.toDouble() : 0.0;

    return Comment(
      id: doc.id,
      hikeId: (data['hikeId'] ?? '') as String,
      userId: (data['userId'] ?? '') as String,
      userEmail: (data['userEmail'] ?? '') as String,
      rating: rating,
      text: (data['text'] ?? '') as String,
      dateTime: dt,
    );
  }

  Map<String, dynamic> toFirestore({required String hikeId}) {
    return {
      'hikeId': hikeId,
      'userId': userId,
      'userEmail': userEmail,
      'rating': rating,
      'text': text,
      'dateTime': Timestamp.fromDate(dateTime),
    };
  }
}
