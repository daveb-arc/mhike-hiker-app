import 'package:cloud_firestore/cloud_firestore.dart';

class Observation {
  final String? id;
  final String hikeId;
  final String title;
  final String category;
  final String detail;
  final DateTime dateTime;

  Observation({
    this.id,
    required this.hikeId,
    required this.title,
    required this.category,
    required this.detail,
    required this.dateTime,
  });

  factory Observation.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final ts = data['dateTime'];
    final dt = ts is Timestamp ? ts.toDate() : DateTime.now();

    return Observation(
      id: doc.id,
      hikeId: (data['hikeId'] ?? '') as String,
      title: (data['title'] ?? '') as String,
      category: (data['category'] ?? '') as String,
      detail: (data['detail'] ?? '') as String,
      dateTime: dt,
    );
  }

  Map<String, dynamic> toFirestore({required String hikeId}) {
    return {
      'hikeId': hikeId,
      'title': title,
      'category': category,
      'detail': detail,
      'dateTime': Timestamp.fromDate(dateTime),
    };
  }
}
