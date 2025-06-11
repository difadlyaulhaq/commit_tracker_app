class UserModel {
  final String uid;
  final String email;
  final String githubUsername;
  final String githubToken;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.githubUsername,
    required this.githubToken,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'githubUsername': githubUsername,
      'githubToken': githubToken,
      'createdAt': createdAt?.millisecondsSinceEpoch,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      githubUsername: map['githubUsername'] ?? '',
      githubToken: map['githubToken'] ?? '',
      createdAt: map['createdAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : null,
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? githubUsername,
    String? githubToken,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      githubUsername: githubUsername ?? this.githubUsername,
      githubToken: githubToken ?? this.githubToken,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}