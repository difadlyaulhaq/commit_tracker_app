import 'dart:convert';
import 'package:http/http.dart' as http;

class GitHubService {
  static const String baseUrl = 'https://api.github.com';

  Future<List<DateTime>> getUserCommits(String username, String token) async {
    final commits = <DateTime>[];
    final now = DateTime.now();
    final oneYearAgo = now.subtract(Duration(days: 365));

    try {
      // Get user's repositories
      final reposResponse = await http.get(
        Uri.parse('$baseUrl/user/repos?per_page=100'),
        headers: {
          'Authorization': 'token $token',
          'Accept': 'application/vnd.github.v3+json',
        },
      );

      if (reposResponse.statusCode == 200) {
        final repos = json.decode(reposResponse.body) as List;
        
        for (final repo in repos) {
          final repoName = repo['name'];
          final ownerLogin = repo['owner']['login'];
          
          // Get commits for each repository
          final commitsResponse = await http.get(
            Uri.parse('$baseUrl/repos/$ownerLogin/$repoName/commits?author=$username&since=${oneYearAgo.toIso8601String()}'),
            headers: {
              'Authorization': 'token $token',
              'Accept': 'application/vnd.github.v3+json',
            },
          );

          if (commitsResponse.statusCode == 200) {
            final repoCommits = json.decode(commitsResponse.body) as List;
            
            for (final commit in repoCommits) {
              final dateStr = commit['commit']['author']['date'];
              final commitDate = DateTime.parse(dateStr);
              commits.add(commitDate);
            }
          }
        }
      }
    } catch (e) {
      throw Exception('Failed to fetch GitHub commits: $e');
    }

    return commits;
  }
}
