import 'dart:convert';
import 'package:http/http.dart' as http;

class GitHubService {
  static const String baseUrl = 'https://api.github.com';

  Future<List<DateTime>> getUserCommits(String username, String token) async {
    final commits = <DateTime>[];
    
    try {
      print('Fetching commits for user: $username');
      
      // Gunakan GraphQL API untuk mendapatkan semua data contributions
      final contributionsData = await _getAllContributionsData(username, token);
      
      if (contributionsData['data'] != null && 
          contributionsData['data']['user'] != null) {
        final contributionCalendar = contributionsData['data']['user']
            ['contributionsCollection']['contributionCalendar'];
        
        final weeks = contributionCalendar['weeks'] as List;
        
        for (final week in weeks) {
          final days = week['contributionDays'] as List;
          for (final day in days) {
            final contributionCount = day['contributionCount'] as int;
            if (contributionCount > 0) {
              final date = DateTime.parse(day['date']);
              // Tambahkan commit sesuai dengan jumlah contribution
              for (int i = 0; i < contributionCount; i++) {
                commits.add(date);
              }
            }
          }
        }
      }
      
      print('Total commits found: ${commits.length}');
      
    } catch (e) {
      print('Error fetching commits: $e');
      // Fallback ke REST API jika GraphQL gagal
      await _getAllRepositoriesCommits(username, token, commits);
    }

    return commits;
  }

  // Metode untuk mendapatkan semua contributions dari berbagai tahun
  Future<Map<String, dynamic>> _getAllContributionsData(String username, String token) async {
    final now = DateTime.now();
    final allContributions = <String, dynamic>{
      'data': {
        'user': {
          'contributionsCollection': {
            'totalCommitContributions': 0,
            'contributionCalendar': {
              'totalContributions': 0,
              'weeks': <dynamic>[]
            }
          }
        }
      }
    };

    // Fetch contributions untuk setiap tahun dari 2020 sampai sekarang
    final startYear = 2020; // Mulai dari tahun 2020
    final currentYear = now.year;
    
    int totalCommitContributions = 0;
    final List<dynamic> allWeeks = [];

    for (int year = startYear; year <= currentYear; year++) {
      try {
        final yearStart = DateTime(year, 1, 1);
        final yearEnd = year == currentYear ? now : DateTime(year, 12, 31, 23, 59, 59);
        
        print('Fetching contributions for year: $year');
        
        final yearContributions = await _getContributionsForYear(username, token, yearStart, yearEnd);
        
        if (yearContributions['data'] != null && 
            yearContributions['data']['user'] != null) {
          final yearCollection = yearContributions['data']['user']['contributionsCollection'];
          
          totalCommitContributions += (yearCollection['totalCommitContributions'] ?? 0) as int;
          
          final yearWeeks = yearCollection['contributionCalendar']['weeks'] as List;
          allWeeks.addAll(yearWeeks);
        }
        
        // Tambahkan delay kecil untuk menghindari rate limiting
        await Future.delayed(Duration(milliseconds: 100));
        
      } catch (e) {
        print('Error fetching contributions for year $year: $e');
        continue;
      }
    }

    // Update total contributions
    allContributions['data']['user']['contributionsCollection']['totalCommitContributions'] = totalCommitContributions;
    allContributions['data']['user']['contributionsCollection']['contributionCalendar']['weeks'] = allWeeks;
    allContributions['data']['user']['contributionsCollection']['contributionCalendar']['totalContributions'] = totalCommitContributions;

    print('Total contributions across all years: $totalCommitContributions');
    return allContributions;
  }

  // Metode untuk mendapatkan contributions untuk tahun tertentu
  Future<Map<String, dynamic>> _getContributionsForYear(String username, String token, DateTime from, DateTime to) async {
    final String query = '''
    query(\$username: String!, \$from: DateTime!, \$to: DateTime!) {
      user(login: \$username) {
        contributionsCollection(from: \$from, to: \$to) {
          totalCommitContributions
          contributionCalendar {
            totalContributions
            weeks {
              contributionDays {
                date
                contributionCount
              }
            }
          }
        }
      }
    }
    ''';

    final response = await http.post(
      Uri.parse('https://api.github.com/graphql'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'User-Agent': 'Flutter-App',
      },
      body: json.encode({
        'query': query,
        'variables': {
          'username': username,
          'from': from.toIso8601String(),
          'to': to.toIso8601String(),
        },
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      print('GraphQL Error for year ${from.year}: ${response.body}');
      throw Exception('Failed to fetch contributions data: ${response.statusCode}');
    }
  }

  // Metode fallback untuk mendapatkan semua repository dengan paginasi (improved)
  Future<void> _getAllRepositoriesCommits(String username, String token, List<DateTime> commits) async {
    print('Using fallback REST API method');
    int page = 1;
    bool hasMore = true;
    
    // Tingkatkan limit halaman untuk mendapatkan lebih banyak data
    int maxPages = 20;

    while (hasMore && page <= maxPages) {
      try {
        final reposResponse = await http.get(
          Uri.parse('$baseUrl/user/repos?per_page=100&page=$page&type=all&sort=updated'),
          headers: {
            'Authorization': 'token $token',
            'Accept': 'application/vnd.github.v3+json',
            'User-Agent': 'Flutter-App',
          },
        );

        print('Repos API Response Status: ${reposResponse.statusCode}');

        if (reposResponse.statusCode == 200) {
          final repos = json.decode(reposResponse.body) as List;
          
          if (repos.isEmpty) {
            hasMore = false;
            break;
          }

          print('Found ${repos.length} repos on page $page');

          for (final repo in repos) {
            await _getRepositoryCommits(repo, username, token, commits);
          }

          page++;
        } else {
          print('Error fetching repos: ${reposResponse.body}');
          hasMore = false;
        }
      } catch (e) {
        print('Error in repository pagination: $e');
        hasMore = false;
      }
    }
  }

  // Metode untuk mendapatkan commit dari repository tertentu (improved)
  Future<void> _getRepositoryCommits(Map<String, dynamic> repo, String username, String token, List<DateTime> commits) async {
    final repoName = repo['name'];
    final ownerLogin = repo['owner']['login'];
    
    // Jangan skip repo lama, karena kita ingin semua commits
    
    int page = 1;
    bool hasMore = true;
    int maxPages = 10; // Batasi per repo

    while (hasMore && page <= maxPages) {
      try {
        // Hapus filter 'since' untuk mendapatkan semua commits
        final commitsResponse = await http.get(
          Uri.parse('$baseUrl/repos/$ownerLogin/$repoName/commits?author=$username&per_page=100&page=$page'),
          headers: {
            'Authorization': 'token $token',
            'Accept': 'application/vnd.github.v3+json',
            'User-Agent': 'Flutter-App',
          },
        );

        if (commitsResponse.statusCode == 200) {
          final repoCommits = json.decode(commitsResponse.body) as List;
          
          if (repoCommits.isEmpty) {
            hasMore = false;
            break;
          }

          for (final commit in repoCommits) {
            try {
              final dateStr = commit['commit']['author']['date'];
              final commitDate = DateTime.parse(dateStr);
              commits.add(commitDate);
            } catch (e) {
              print('Error parsing commit date: $e');
            }
          }

          page++;
        } else {
          hasMore = false;
        }
      } catch (e) {
        print('Error fetching commits for repo $repoName: $e');
        hasMore = false;
      }
    }
  }

  // Metode untuk mendapatkan statistik commit hari ini
  Future<int> getTodayCommitCount(String username, String token) async {
    try {
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      final todayEnd = todayStart.add(Duration(days: 1));

      // Gunakan GraphQL untuk mendapatkan data hari ini
      final contributionsData = await _getContributionsForYear(username, token, todayStart, todayEnd);
      
      if (contributionsData['data'] != null && 
          contributionsData['data']['user'] != null) {
        final contributionCalendar = contributionsData['data']['user']
            ['contributionsCollection']['contributionCalendar'];
        
        final weeks = contributionCalendar['weeks'] as List;
        
        // Cari contribution untuk hari ini
        for (final week in weeks) {
          final days = week['contributionDays'] as List;
          for (final day in days) {
            final dayDate = DateTime.parse(day['date']);
            if (dayDate.year == today.year && 
                dayDate.month == today.month && 
                dayDate.day == today.day) {
              return day['contributionCount'] as int;
            }
          }
        }
      }
      
      return 0;
    } catch (e) {
      print('Error getting today commit count: $e');
      return 0;
    }
  }

  // Metode untuk mendapatkan total commit sepanjang masa (improved)
  Future<int> getTotalCommitCount(String username, String token) async {
    try {
      print('Getting total commit count for: $username');
      
      // Gunakan GraphQL untuk mendapatkan total contributions dari semua tahun
      final contributionsData = await _getAllContributionsData(username, token);
      
      if (contributionsData['data'] != null && 
          contributionsData['data']['user'] != null) {
        final totalCommitContributions = contributionsData['data']['user']
            ['contributionsCollection']['totalCommitContributions'];
        
        print('Total commit contributions from GraphQL: $totalCommitContributions');
        return totalCommitContributions as int;
      }
      
      // Fallback ke search API dengan query yang lebih spesifik
      final searchResponse = await http.get(
        Uri.parse('$baseUrl/search/commits?q=author:$username+type:commit'),
        headers: {
          'Authorization': 'token $token',
          'Accept': 'application/vnd.github.cloak-preview',
          'User-Agent': 'Flutter-App',
        },
      );

      if (searchResponse.statusCode == 200) {
        final searchData = json.decode(searchResponse.body);
        final totalCount = searchData['total_count'] ?? 0;
        print('Total commits from search API: $totalCount');
        return totalCount;
      }
      
      print('Search API failed, status: ${searchResponse.statusCode}');
      return 0;
      
    } catch (e) {
      print('Error getting total commit count: $e');
      return 0;
    }
  }

  // Metode untuk mendapatkan current streak (improved)
  int calculateCurrentStreak(List<DateTime> commits) {
    if (commits.isEmpty) return 0;

    print('Calculating streak from ${commits.length} commits');

    // Group commits by date
    final Map<String, int> commitsByDate = {};
    for (final commit in commits) {
      final dateKey = '${commit.year}-${commit.month.toString().padLeft(2, '0')}-${commit.day.toString().padLeft(2, '0')}';
      commitsByDate[dateKey] = (commitsByDate[dateKey] ?? 0) + 1;
    }

    print('Commits grouped by date: ${commitsByDate.length} unique days');

    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    int streak = 0;
    DateTime currentDay = today;

    // Mulai dari hari ini dan mundur
    while (true) {
      final dayKey = '${currentDay.year}-${currentDay.month.toString().padLeft(2, '0')}-${currentDay.day.toString().padLeft(2, '0')}';
      
      if (commitsByDate.containsKey(dayKey) && commitsByDate[dayKey]! > 0) {
        streak++;
        currentDay = currentDay.subtract(Duration(days: 1));
      } else {
        // Jika hari ini tidak ada commit, coba dari kemarin
        if (streak == 0 && dayKey == todayKey) {
          currentDay = currentDay.subtract(Duration(days: 1));
          continue;
        }
        break;
      }
      
      // Tingkatkan limit untuk streak yang lebih panjang
      if (streak >= 2000) break;
    }

    print('Calculated streak: $streak');
    return streak;
  }
  
  // Method untuk test koneksi GitHub API
  Future<bool> testConnection(String username, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: {
          'Authorization': 'token $token',
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'Flutter-App',
        },
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }

  // Method tambahan untuk mendapatkan statistik contributions per tahun
  Future<Map<int, int>> getContributionsByYear(String username, String token) async {
    final contributionsByYear = <int, int>{};
    
    try {
      final now = DateTime.now();
      final startYear = 2020;
      final currentYear = now.year;
      
      for (int year = startYear; year <= currentYear; year++) {
        final yearStart = DateTime(year, 1, 1);
        final yearEnd = year == currentYear ? now : DateTime(year, 12, 31, 23, 59, 59);
        
        final yearContributions = await _getContributionsForYear(username, token, yearStart, yearEnd);
        
        if (yearContributions['data'] != null && 
            yearContributions['data']['user'] != null) {
          final totalContributions = yearContributions['data']['user']
              ['contributionsCollection']['totalCommitContributions'] as int;
          
          contributionsByYear[year] = totalContributions;
        }
        
        await Future.delayed(Duration(milliseconds: 100));
      }
    } catch (e) {
      print('Error getting contributions by year: $e');
    }
    
    return contributionsByYear;
  }
}