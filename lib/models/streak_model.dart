import 'package:flutter/material.dart';

class StreakModel {
  final int currentStreak;
  final int totalCommits;
  final DateTime lastCommitDate;
  final bool hasCommittedToday;

  StreakModel({
    required this.currentStreak,
    required this.totalCommits,
    required this.lastCommitDate,
    required this.hasCommittedToday,
  });

  Color getFlameColor() {
    if (!hasCommittedToday) return Colors.grey;
    if (totalCommits >= 1000) return Colors.purple;
    if (totalCommits >= 500) return Colors.blue;
    if (totalCommits >= 200) return Colors.purple[300]!;
    return Colors.red;
  }

  Map<String, dynamic> toMap() {
    return {
      'currentStreak': currentStreak,
      'totalCommits': totalCommits,
      'lastCommitDate': lastCommitDate.millisecondsSinceEpoch,
      'hasCommittedToday': hasCommittedToday,
    };
  }

  factory StreakModel.fromMap(Map<String, dynamic> map) {
    return StreakModel(
      currentStreak: map['currentStreak'] ?? 0,
      totalCommits: map['totalCommits'] ?? 0,
      lastCommitDate: DateTime.fromMillisecondsSinceEpoch(map['lastCommitDate'] ?? 0),
      hasCommittedToday: map['hasCommittedToday'] ?? false,
    );
  }
}
