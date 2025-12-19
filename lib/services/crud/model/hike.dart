import 'package:cloud_firestore/cloud_firestore.dart';

class Hike {
  final String? id;

  // owner
  final String userId;
  final String userEmail;

  // content
  final String coverImage; // base64 string
  final String title;
  final String location;
  final double length;
  final String estimatedTime;
  final String description;

  // metadata
  final bool parking;
  final String difficulty;
  final DateTime date;

  // used by home "Popular" filter: (h.popularityIndex ?? 999999) < 10
  final int? popularityIndex;

  const Hike({
    this.id,
    required this.userId,
    required this.userEmail,
    required this.coverImage,
    required this.title,
    required this.location,
    required this.length,
    required this.estimatedTime,
    required this.description,
    required this.parking,
    required this.difficulty,
    required this.date,
    this.popularityIndex,
  });

  Hike copyWith({
    String? id,
    String? userId,
    String? userEmail,
    String? coverImage,
    String? title,
    String? location,
    double? length,
    String? estimatedTime,
    String? description,
    bool? parking,
    String? difficulty,
    DateTime? date,
    int? popularityIndex,
  }) {
    return Hike(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      coverImage: coverImage ?? this.coverImage,
      title: title ?? this.title,
      location: location ?? this.location,
      length: length ?? this.length,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      description: description ?? this.description,
      parking: parking ?? this.parking,
      difficulty: difficulty ?? this.difficulty,
      date: date ?? this.date,
      popularityIndex: popularityIndex ?? this.popularityIndex,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'coverImage': coverImage,
      'title': title,
      'location': location,
      'length': length,
      'estimatedTime': estimatedTime,
      'description': description,
      'parking': parking,
      'difficulty': difficulty,
      'date': Timestamp.fromDate(date),
      'popularityIndex': popularityIndex,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory Hike.fromDoc(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};

    DateTime dt;
    final rawDate = data['date'];
    if (rawDate is Timestamp) {
      dt = rawDate.toDate();
    } else {
      dt = DateTime.now();
    }

    return Hike(
      id: doc.id,
      userId: (data['userId'] ?? '') as String,
      userEmail: (data['userEmail'] ?? '') as String,
      coverImage: (data['coverImage'] ?? '') as String,
      title: (data['title'] ?? '') as String,
      location: (data['location'] ?? '') as String,
      length: (data['length'] ?? 0).toDouble(),
      estimatedTime: (data['estimatedTime'] ?? '') as String,
      description: (data['description'] ?? '') as String,
      parking: (data['parking'] ?? false) as bool,
      difficulty: (data['difficulty'] ?? '') as String,
      date: dt,
      popularityIndex: (data['popularityIndex'] is int)
          ? data['popularityIndex'] as int
          : (data['popularityIndex'] is num)
              ? (data['popularityIndex'] as num).toInt()
              : null,
    );
  }
}
