import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

@immutable
class User {
  final String? id; // Firestore doc id or Firebase uid
  final String email;
  final String username;
  final String fullName;

  const User({
    this.id,
    required this.email,
    required this.username,
    required this.fullName,
  });

  factory User.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return User(
      id: doc.id,
      email: (data['email'] ?? '') as String,
      username: (data['username'] ?? '') as String,
      fullName: (data['fullName'] ?? '') as String,
    );
  }

  Map<String, dynamic> toFirestore({required String uid}) => {
        'uid': uid,
        'email': email,
        'username': username,
        'fullName': fullName,
        'updatedAt': FieldValue.serverTimestamp(),
      };

  User copyWith({
    String? id,
    String? email,
    String? username,
    String? fullName,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
    );
  }
}
