import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/streak_model.dart';
import '../services/github_service.dart';
import '../services/firestore_service.dart';

// Streak Events
abstract class StreakEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadStreak extends StreakEvent {
  final String userId;
  LoadStreak(this.userId);
  @override
  List<Object> get props => [userId];
}

class RefreshStreak extends StreakEvent {
  final String userId;
  final String githubUsername;
  final String githubToken;

  RefreshStreak({
    required this.userId,
    required this.githubUsername,
    required this.githubToken,
  });

  @override
  List<Object> get props => [userId, githubUsername, githubToken];
}

// Streak States
abstract class StreakState extends Equatable {
  @override
  List<Object> get props => [];
}

class StreakInitial extends StreakState {}

class StreakLoading extends StreakState {}

class StreakLoaded extends StreakState {
  final StreakModel streak;

  StreakLoaded(this.streak);

  @override
  List<Object> get props => [streak];
}

class StreakError extends StreakState {
  final String message;

  StreakError(this.message);

  @override
  List<Object> get props => [message];
}

// Streak Bloc
class StreakBloc extends Bloc<StreakEvent, StreakState> {
  final GitHubService _gitHubService = GitHubService();
  final FirestoreService _firestoreService = FirestoreService();

  StreakBloc() : super(StreakInitial()) {
    on<LoadStreak>(_onLoadStreak);
    on<RefreshStreak>(_onRefreshStreak);
  }

  void _onLoadStreak(LoadStreak event, Emitter<StreakState> emit) async {
    emit(StreakLoading());
    try {
      final streak = await _firestoreService.getStreak(event.userId);
      emit(StreakLoaded(streak));
    } catch (e) {
      emit(StreakError(e.toString()));
    }
  }

  void _onRefreshStreak(RefreshStreak event, Emitter<StreakState> emit) async {
    emit(StreakLoading());
    try {
      final commits = await _gitHubService.getUserCommits(
        event.githubUsername,
        event.githubToken,
      );
      
      final streak = _calculateStreak(commits);
      await _firestoreService.saveStreak(event.userId, streak);
      emit(StreakLoaded(streak));
    } catch (e) {
      emit(StreakError(e.toString()));
    }
  }

  StreakModel _calculateStreak(List<DateTime> commits) {
    if (commits.isEmpty) {
      return StreakModel(
        currentStreak: 0,
        totalCommits: 0,
        lastCommitDate: DateTime.now(),
        hasCommittedToday: false,
      );
    }

    commits.sort((a, b) => b.compareTo(a));
    
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    
    bool hasCommittedToday = false;
    int currentStreak = 0;
    
    // Check if there's a commit today
    for (final commit in commits) {
      final commitDate = DateTime(commit.year, commit.month, commit.day);
      if (commitDate.isAtSameMomentAs(todayDate)) {
        hasCommittedToday = true;
        break;
      }
    }

    // Calculate streak
    DateTime checkDate = todayDate;
    if (!hasCommittedToday) {
      checkDate = todayDate.subtract(Duration(days: 1));
    }

    while (true) {
      bool hasCommitOnDate = commits.any((commit) {
        final commitDate = DateTime(commit.year, commit.month, commit.day);
        return commitDate.isAtSameMomentAs(checkDate);
      });

      if (hasCommitOnDate) {
        currentStreak++;
        checkDate = checkDate.subtract(Duration(days: 1));
      } else {
        break;
      }
    }

    return StreakModel(
      currentStreak: currentStreak,
      totalCommits: commits.length,
      lastCommitDate: commits.first,
      hasCommittedToday: hasCommittedToday,
    );
  }
}
