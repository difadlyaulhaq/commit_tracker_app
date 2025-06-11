import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel extends Equatable {
  final String uid;
  final String email;
  final String githubUsername;
  final String githubToken;
  final DateTime createdAt;
  final DateTime lastLoginAt;

  const UserModel({
    required this.uid,
    required this.email,
    required this.githubUsername,
    required this.githubToken,
    required this.createdAt,
    required this.lastLoginAt,
  });

  // Convert to Map untuk Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'githubUsername': githubUsername,
      'githubToken': githubToken,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
    };
  }

  // Create from Map dari Firestore
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      githubUsername: map['githubUsername'] ?? '',
      githubToken: map['githubToken'] ?? '',
      createdAt: _parseDateTime(map['createdAt']),
      lastLoginAt: _parseDateTime(map['lastLoginAt']),
    );
  }

  // Helper method untuk parse DateTime dari berbagai format
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) {
      return DateTime.now();
    }
    
    // Jika sudah DateTime
    if (value is DateTime) {
      return value;
    }
    
    // Jika Firestore Timestamp
    if (value is Timestamp) {
      return value.toDate();
    }
    
    // Jika int (milliseconds since epoch)
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    
    // Jika string
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    
    // Default fallback
    return DateTime.now();
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? githubUsername,
    String? githubToken,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      githubUsername: githubUsername ?? this.githubUsername,
      githubToken: githubToken ?? this.githubToken,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  List<Object> get props => [
    uid,
    email,
    githubUsername,
    githubToken,
    createdAt,
    lastLoginAt,
  ];

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, githubUsername: $githubUsername)';
  }
}