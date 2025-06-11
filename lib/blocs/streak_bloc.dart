import 'dart:async';

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
  final GitHubService _githubService;
  final FirestoreService _firestoreService;

  StreakBloc(this._githubService, this._firestoreService) : super(StreakInitial()) {
    on<LoadStreak>(_onLoadStreak);
    on<RefreshStreak>(_onRefreshStreak);
  }

  Future<void> _onLoadStreak(LoadStreak event, Emitter<StreakState> emit) async {
    emit(StreakLoading());
    
    try {
      print('Loading streak for user: ${event.userId}');
      
      final streak = await _firestoreService.getUserStreak(event.userId);
      if (streak != null) {
        print('Loaded streak from Firestore: $streak');
        emit(StreakLoaded(streak));
      } else {
        print('No streak data found, creating default');
        // Jika tidak ada data, buat default
        final defaultStreak = StreakModel(
          currentStreak: 0,
          totalCommits: 0,
          lastCommitDate: DateTime.now(),
          hasCommittedToday: false,
          todayCommits: 0,
          lastUpdated: DateTime.now(),
        );
        emit(StreakLoaded(defaultStreak));
      }
    } catch (e, stackTrace) {
      print('Error loading streak: $e');
      print('Stack trace: $stackTrace');
      
      // Jika error terkait timestamp, coba dengan default data
      if (e.toString().contains('Timestamp') || e.toString().contains('subtype')) {
        try {
          final defaultStreak = StreakModel(
            currentStreak: 0,
            totalCommits: 0,
            lastCommitDate: DateTime.now(),
            hasCommittedToday: false,
            todayCommits: 0,
            lastUpdated: DateTime.now(),
          );
          emit(StreakLoaded(defaultStreak));
        } catch (e2) {
          emit(StreakError('Failed to load streak: ${e2.toString()}'));
        }
      } else {
        emit(StreakError('Failed to load streak: ${e.toString()}'));
      }
    }
  }

  Future<void> _onRefreshStreak(RefreshStreak event, Emitter<StreakState> emit) async {
    emit(StreakLoading());
    
    try {
      print('Refreshing streak for user: ${event.userId}');
      print('GitHub username: ${event.githubUsername}');
      
      // Test koneksi GitHub terlebih dahulu
      final isConnected = await _githubService.testConnection(event.githubUsername, event.githubToken);
      if (!isConnected) {
        emit(StreakError('Failed to connect to GitHub. Please check your username and token.'));
        return;
      }
      
      print('GitHub connection successful');
      
      // Set timeout untuk operasi GitHub API
      final Future<List<DateTime>> commitsOperation = _githubService.getUserCommits(
        event.githubUsername, 
        event.githubToken
      );
      
      final Future<int> totalCommitsOperation = _githubService.getTotalCommitCount(
        event.githubUsername,
        event.githubToken
      );
      
      final Future<int> todayCommitsOperation = _githubService.getTodayCommitCount(
        event.githubUsername,
        event.githubToken
      );
      
      // Jalankan semua operasi dengan timeout
      final results = await Future.wait([
        commitsOperation.timeout(Duration(seconds: 30)),
        totalCommitsOperation.timeout(Duration(seconds: 15)),
        todayCommitsOperation.timeout(Duration(seconds: 10)),
      ]).timeout(Duration(seconds: 45));
      
      final commits = results[0] as List<DateTime>;
      final totalCommits = results[1] as int;
      final todayCommits = results[2] as int;
      
      print('GitHub API results:');
      print('- Total commits: $totalCommits');
      print('- Today commits: $todayCommits');
      print('- Commits list length: ${commits.length}');

      // Hitung current streak
      final currentStreak = _githubService.calculateCurrentStreak(commits);
      print('Calculated current streak: $currentStreak');

      // Cek apakah sudah commit hari ini
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      final hasCommittedToday = todayCommits > 0;
      
      print('Has committed today: $hasCommittedToday');

      // Dapatkan tanggal commit terakhir
      DateTime lastCommitDate = DateTime.now();
      if (commits.isNotEmpty) {
        // Urutkan commits dan ambil yang terbaru
        commits.sort((a, b) => b.compareTo(a));
        lastCommitDate = commits.first;
      }
      
      print('Last commit date: $lastCommitDate');

      // Buat model streak baru dengan data yang akurat
      final streak = StreakModel(
        currentStreak: currentStreak,
        totalCommits: totalCommits,
        lastCommitDate: lastCommitDate,
        hasCommittedToday: hasCommittedToday,
        todayCommits: todayCommits,
        lastUpdated: DateTime.now(),
      );

      print('Created streak model: $streak');

      // Simpan ke Firestore
      await _firestoreService.updateUserStreak(event.userId, streak);
      print('Saved streak to Firestore');

      emit(StreakLoaded(streak));
      
    } on TimeoutException catch (e) {
      print('Timeout error: $e');
      emit(StreakError('Request timeout. Please check your internet connection and try again.'));
    } catch (e, stackTrace) {
      print('Error refreshing streak: $e');
      print('Stack trace: $stackTrace');
      
      String errorMessage = 'Failed to refresh streak';
      
      if (e.toString().contains('SocketException')) {
        errorMessage = 'No internet connection. Please check your network.';
      } else if (e.toString().contains('401')) {
        errorMessage = 'Invalid GitHub token. Please check your token.';
      } else if (e.toString().contains('403')) {
        errorMessage = 'GitHub API rate limit exceeded. Please try again later.';
      } else if (e.toString().contains('404')) {
        errorMessage = 'GitHub user not found. Please check your username.';
      } else {
        errorMessage = 'Failed to refresh streak: ${e.toString()}';
      }
      
      emit(StreakError(errorMessage));
    }
  }
}