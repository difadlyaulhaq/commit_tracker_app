import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StreakModel extends Equatable {
  final int currentStreak;
  final int totalCommits;
  final DateTime lastCommitDate;
  final bool hasCommittedToday;
  final int todayCommits;
  final DateTime lastUpdated;

   StreakModel({
    required this.currentStreak,
    required this.totalCommits,
    required this.lastCommitDate,
    required this.hasCommittedToday,
    this.todayCommits = 0,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ??  DateTime.fromMillisecondsSinceEpoch(0);

  Color getFlameColor() {
    if (!hasCommittedToday) return Colors.grey;
    
    if (totalCommits >= 1000) return Colors.purple;
    if (totalCommits >= 500) return Colors.blue;
    if (totalCommits >= 200) return Colors.purple[300]!;
    
    if (currentStreak >= 100) return Colors.deepPurple;
    if (currentStreak >= 50) return Colors.indigo;
    if (currentStreak >= 30) return Colors.blue;
    if (currentStreak >= 14) return Colors.green;
    if (currentStreak >= 7) return Colors.orange;
    
    return Colors.red;
  }

  double getFlameIntensity() {
    if (!hasCommittedToday) return 0.3;
    
    if (todayCommits >= 10) return 1.0;
    if (todayCommits >= 5) return 0.8;
    if (todayCommits >= 3) return 0.6;
    if (todayCommits >= 1) return 0.4;
    
    return 0.3;
  }

  String getStreakStatus() {
    if (!hasCommittedToday) {
      final daysSinceLastCommit = DateTime.now().difference(lastCommitDate).inDays;
      if (daysSinceLastCommit > 1) {
        return 'Streak broken! Last commit: ${daysSinceLastCommit} days ago';
      }
      return 'No commits today';
    }
    
    if (currentStreak == 1) return 'Great start! Keep it up!';
    if (currentStreak < 7) return 'Building momentum...';
    if (currentStreak < 30) return 'On fire! 🔥';
    if (currentStreak < 100) return 'Incredible streak! 💪';
    return 'Legendary streak! 🏆';
  }

  String getStreakEmoji() {
    if (!hasCommittedToday) return '😴';
    if (currentStreak >= 100) return '🏆';
    if (currentStreak >= 50) return '💎';
    if (currentStreak >= 30) return '🚀';
    if (currentStreak >= 14) return '🔥';
    if (currentStreak >= 7) return '⚡';
    return '💪';
  }

  // Method untuk mengconvert ke Map (untuk Firestore)
  Map<String, dynamic> toMap() {
    return {
      'currentStreak': currentStreak,
      'totalCommits': totalCommits,
      'lastCommitDate': Timestamp.fromDate(lastCommitDate), // Gunakan Firestore Timestamp
      'hasCommittedToday': hasCommittedToday,
      'todayCommits': todayCommits,
      'lastUpdated': Timestamp.fromDate(lastUpdated), // Gunakan Firestore Timestamp
    };
  }

  // Factory constructor untuk membuat instance dari Map (dari Firestore)
  factory StreakModel.fromMap(Map<String, dynamic> map) {
    return StreakModel(
      currentStreak: map['currentStreak']?.toInt() ?? 0,
      totalCommits: map['totalCommits']?.toInt() ?? 0,
      lastCommitDate: _parseDateTime(map['lastCommitDate']),
      hasCommittedToday: map['hasCommittedToday'] ?? false,
      todayCommits: map['todayCommits']?.toInt() ?? 0,
      lastUpdated: _parseDateTime(map['lastUpdated']),
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

  StreakModel copyWith({
    int? currentStreak,
    int? totalCommits,
    DateTime? lastCommitDate,
    bool? hasCommittedToday,
    int? todayCommits,
    DateTime? lastUpdated,
  }) {
    return StreakModel(
      currentStreak: currentStreak ?? this.currentStreak,
      totalCommits: totalCommits ?? this.totalCommits,
      lastCommitDate: lastCommitDate ?? this.lastCommitDate,
      hasCommittedToday: hasCommittedToday ?? this.hasCommittedToday,
      todayCommits: todayCommits ?? this.todayCommits,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory StreakModel.fromJson(Map<String, dynamic> json) => StreakModel.fromMap(json);

  @override
  String toString() {
    return 'StreakModel(currentStreak: $currentStreak, totalCommits: $totalCommits, '
           'lastCommitDate: $lastCommitDate, hasCommittedToday: $hasCommittedToday, '
           'todayCommits: $todayCommits, lastUpdated: $lastUpdated)';
  }

  @override
  List<Object?> get props => [
    currentStreak,
    totalCommits,
    lastCommitDate,
    hasCommittedToday,
    todayCommits,
    lastUpdated,
  ];

  bool isValid() {
    return currentStreak >= 0 &&
           totalCommits >= 0 &&
           todayCommits >= 0 &&
           lastCommitDate != null;
  }

  Map<String, dynamic> getNextMilestone() {
    final milestones = [7, 14, 30, 50, 100, 200, 365, 500, 1000];
    
    for (final milestone in milestones) {
      if (currentStreak < milestone) {
        return {
          'target': milestone,
          'remaining': milestone - currentStreak,
          'progress': currentStreak / milestone,
        };
      }
    }
    
    return {
      'target': currentStreak + 100,
      'remaining': 100,
      'progress': 0.0,
    };
  }
}