import 'package:flutter/material.dart';
import '../models/streak_model.dart';

class StreakStats extends StatelessWidget {
  final StreakModel streak;

  StreakStats({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF21262D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                'Current Streak',
                '${streak.currentStreak}',
                Icons.local_fire_department,
                Colors.orange,
              ),
              _buildStatItem(
                'Total Commits',
                '${streak.totalCommits}',
                Icons.commit,
                Colors.green,
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildMilestoneProgress(),
          SizedBox(height: 16),
          Text(
            'Last commit: ${_formatDate(streak.lastCommitDate)}',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 30),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildMilestoneProgress() {
    final milestones = [200, 500, 1000];
    final currentCommits = streak.totalCommits;
    
    int nextMilestone = milestones.firstWhere(
      (milestone) => milestone > currentCommits,
      orElse: () => 1000,
    );

    double progress = currentCommits / nextMilestone;
    if (progress > 1.0) progress = 1.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Next Milestone',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            Text(
              '$currentCommits / $nextMilestone',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
          ],
        ),
        SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[800],
          valueColor: AlwaysStoppedAnimation<Color>(_getMilestoneColor(nextMilestone)),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: milestones.map((milestone) {
            final achieved = currentCommits >= milestone;
            return Column(
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: achieved ? _getMilestoneColor(milestone) : Colors.grey[600],
                  size: 20,
                ),
                Text(
                  '$milestone',
                  style: TextStyle(
                    color: achieved ? _getMilestoneColor(milestone) : Colors.grey[600],
                    fontSize: 12,
                    fontWeight: achieved ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getMilestoneColor(int milestone) {
    switch (milestone) {
      case 200:
        return Colors.purple[300]!;
      case 500:
        return Colors.blue;
      case 1000:
        return Colors.purple;
      default:
        return Colors.orange;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}