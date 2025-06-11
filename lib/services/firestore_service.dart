import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/streak_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collection name untuk menyimpan data streak
  static const String _streaksCollection = 'streaks';

  /// Mendapatkan data streak user dari Firestore
  Future<StreakModel?> getUserStreak(String userId) async {
    try {
      final doc = await _firestore
          .collection(_streaksCollection)
          .doc(userId)
          .get();

      if (doc.exists && doc.data() != null) {
        return StreakModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user streak: $e');
    }
  }

  /// Menyimpan atau memperbarui data streak user ke Firestore
  Future<void> updateUserStreak(String userId, StreakModel streak) async {
    try {
      await _firestore
          .collection(_streaksCollection)
          .doc(userId)
          .set(streak.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update user streak: $e');
    }
  }

  /// Menghapus data streak user dari Firestore
  Future<void> deleteUserStreak(String userId) async {
    try {
      await _firestore
          .collection(_streaksCollection)
          .doc(userId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete user streak: $e');
    }
  }

  /// Mendapatkan semua data streak (untuk admin atau analytics)
  Future<List<StreakModel>> getAllStreaks() async {
    try {
      final querySnapshot = await _firestore
          .collection(_streaksCollection)
          .get();

      return querySnapshot.docs
          .map((doc) => StreakModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get all streaks: $e');
    }
  }

  /// Stream untuk mendapatkan data streak secara real-time
  Stream<StreakModel?> watchUserStreak(String userId) {
    return _firestore
        .collection(_streaksCollection)
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return StreakModel.fromMap(doc.data()!);
      }
      return null;
    });
  }

  /// Menyimpan history streak harian
  Future<void> saveStreakHistory(String userId, Map<String, dynamic> historyData) async {
    try {
      final date = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD format
      
      await _firestore
          .collection(_streaksCollection)
          .doc(userId)
          .collection('history')
          .doc(date)
          .set(historyData, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save streak history: $e');
    }
  }

  /// Mendapatkan history streak dalam rentang waktu tertentu
  Future<List<Map<String, dynamic>>> getStreakHistory(
      String userId, {
      DateTime? startDate,
      DateTime? endDate,
      int? limit,
    }) async {
    try {
      Query query = _firestore
          .collection(_streaksCollection)
          .doc(userId)
          .collection('history');

      if (startDate != null) {
        query = query.where('date', isGreaterThanOrEqualTo: startDate.toIso8601String().split('T')[0]);
      }

      if (endDate != null) {
        query = query.where('date', isLessThanOrEqualTo: endDate.toIso8601String().split('T')[0]);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw Exception('Failed to get streak history: $e');
    }
  }

  /// Batch update untuk performa yang lebih baik
  Future<void> batchUpdateStreaks(Map<String, StreakModel> streaks) async {
    try {
      final batch = _firestore.batch();

      streaks.forEach((userId, streak) {
        final docRef = _firestore
            .collection(_streaksCollection)
            .doc(userId);
        batch.set(docRef, streak.toMap(), SetOptions(merge: true));
      });

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to batch update streaks: $e');
    }
  }

  /// Backup data streak ke collection terpisah
  Future<void> backupUserStreak(String userId) async {
    try {
      final streak = await getUserStreak(userId);
      if (streak != null) {
        await _firestore
            .collection('streak_backups')
            .doc('${userId}_${DateTime.now().millisecondsSinceEpoch}')
            .set({
          'userId': userId,
          'streak': streak.toMap(),
          'backupDate': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to backup user streak: $e');
    }
  }

  /// Restore data streak dari backup
  Future<void> restoreUserStreak(String userId, String backupId) async {
    try {
      final backupDoc = await _firestore
          .collection('streak_backups')
          .doc(backupId)
          .get();

      if (backupDoc.exists && backupDoc.data() != null) {
        final backupData = backupDoc.data()!;
        final streakData = backupData['streak'] as Map<String, dynamic>;
        final streak = StreakModel.fromMap(streakData);
        
        await updateUserStreak(userId, streak);
      }
    } catch (e) {
      throw Exception('Failed to restore user streak: $e');
    }
  }
}