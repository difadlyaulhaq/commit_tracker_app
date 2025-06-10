class UserModel {
  final String uid;
  final String email;
  final String githubUsername;
  final String githubToken;

  UserModel({
    required this.uid,
    required this.email,
    required this.githubUsername,
    required this.githubToken,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'githubUsername': githubUsername,
      'githubToken': githubToken,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      githubUsername: map['githubUsername'] ?? '',
      githubToken: map['githubToken'] ?? '',
    );
  }
}