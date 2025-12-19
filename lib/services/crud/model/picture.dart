import 'package:cloud_firestore/cloud_firestore.dart';

class Picture {
  final String id;
  final String base64;
  final DateTime time;

  Picture({
    required this.id,
    required this.base64,
    required this.time,
  });

  /// ---------- FIRESTORE READ ----------
  factory Picture.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Picture(
      id: doc.id,
      base64: data['base64'] ?? '',
      time: (data['time'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// ---------- FIRESTORE WRITE ----------
  Map<String, dynamic> toMap() {
    return {
      'base64': base64,
      'time': Timestamp.fromDate(time),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
