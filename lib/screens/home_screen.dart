import 'package:commit_tracker/widgets/AnimatedFlameWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/streak_bloc.dart';
import '../widgets/flame_widget.dart';
import '../widgets/streak_stats.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D1117),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthAuthenticated) {
            context.read<StreakBloc>().add(LoadStreak(authState.user.uid));
            
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildHeader(context, authState.user.githubUsername),
                    SizedBox(height: 30),
                    Expanded(
                      child: BlocBuilder<StreakBloc, StreakState>(
                        builder: (context, streakState) {
                          if (streakState is StreakLoading) {
                            return Center(
                              child: CircularProgressIndicator(color: Colors.orange),
                            );
                          } else if (streakState is StreakLoaded) {
                            return Column(
                              children: [
                                // FlameWidget(streak: streakState.streak),
                                AnimatedFlameWidget(streak: streakState.streak),
                                SizedBox(height: 30),
                                StreakStats(streak: streakState.streak),
                                SizedBox(height: 30),
                                _buildRefreshButton(context, authState.user),
                              ],
                            );
                          } else if (streakState is StreakError) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.error, color: Colors.red, size: 60),
                                  SizedBox(height: 16),
                                  Text(
                                    'Error: ${streakState.message}',
                                    style: TextStyle(color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 16),
                                  _buildRefreshButton(context, authState.user),
                                ],
                              ),
                            );
                          }
                          return _buildRefreshButton(context, authState.user);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return Container();
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String username) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, $username!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Keep your streak alive! 🔥',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: () {
            context.read<AuthBloc>().add(LogoutRequested());
          },
          icon: Icon(Icons.logout, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildRefreshButton(BuildContext context, user) {
    return ElevatedButton.icon(
      onPressed: () {
        context.read<StreakBloc>().add(
          RefreshStreak(
            userId: user.uid,
            githubUsername: user.githubUsername,
            githubToken: user.githubToken,
          ),
        );
      },
      icon: Icon(Icons.refresh, color: Colors.white),
      label: Text(
        'Refresh Streak',
        style: TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}