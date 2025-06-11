import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/streak_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<StreakModel> getStreak(String userId) async {
    try {
      final doc = await _firestore.collection('streaks').doc(userId).get();
      if (doc.exists) {
        return StreakModel.fromMap(doc.data()!);
      } else {
        return StreakModel(
          currentStreak: 0,
          totalCommits: 0,
          lastCommitDate: DateTime.now(),
          hasCommittedToday: false,
        );
      }
    } catch (e) {
      throw Exception('Failed to load streak: $e');
    }
  }

  Future<void> saveStreak(String userId, StreakModel streak) async {
    try {
      await _firestore.collection('streaks').doc(userId).set(streak.toMap());
    } catch (e) {
      throw Exception('Failed to save streak: $e');
    }
  }
}