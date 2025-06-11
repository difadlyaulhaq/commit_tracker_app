// screens/github_token_tutorial_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GitHubTokenTutorialScreen extends StatefulWidget {
  @override
  _GitHubTokenTutorialScreenState createState() => _GitHubTokenTutorialScreenState();
}

class _GitHubTokenTutorialScreenState extends State<GitHubTokenTutorialScreen> {
  PageController _pageController = PageController();
  int _currentPage = 0;

  final List<TutorialStep> _steps = [
    TutorialStep(
      title: 'Welcome to GitHub Token Setup',
      description: 'Kita perlu GitHub Personal Access Token untuk mengakses data commit kamu. Jangan khawatir, prosesnya mudah!',
      icon: Icons.waving_hand,
      color: Colors.blue,
      content: _buildWelcomePage(),
    ),
    TutorialStep(
      title: 'Step 1: Buka GitHub Settings',
      description: 'Mari kita mulai dengan membuka pengaturan GitHub',
      icon: Icons.settings,
      color: Colors.green,
      content: _buildStep1(),
    ),
    TutorialStep(
      title: 'Step 2: Developer Settings',
      description: 'Cari menu Developer settings di sidebar',
      icon: Icons.developer_mode,
      color: Colors.orange,
      content: _buildStep2(),
    ),
    TutorialStep(
      title: 'Step 3: Personal Access Tokens',
      description: 'Pilih Personal access tokens untuk membuat token baru',
      icon: Icons.key,
      color: Colors.purple,
      content: _buildStep3(),
    ),
    TutorialStep(
      title: 'Step 4: Generate New Token',
      description: 'Klik Generate new token dan pilih classic',
      icon: Icons.add_circle,
      color: Colors.red,
      content: _buildStep4(),
    ),
    TutorialStep(
      title: 'Step 5: Setup Token',
      description: 'Atur nama token dan pilih permissions yang dibutuhkan',
      icon: Icons.tune,
      color: Colors.teal,
      content: _buildStep5(),
    ),
    TutorialStep(
      title: 'Step 6: Copy Your Token',
      description: 'Salin token yang sudah dibuat dan simpan baik-baik',
      icon: Icons.copy,
      color: Colors.indigo,
      content: _buildStep6(),
    ),
    TutorialStep(
      title: 'Selesai! 🎉',
      description: 'Token sudah siap digunakan di aplikasi',
      icon: Icons.check_circle,
      color: Colors.green,
      content: _buildFinalPage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: Color(0xFF21262D),
        title: Text(
          'GitHub Token Tutorial',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: List.generate(_steps.length, (index) {
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: index <= _currentPage ? Colors.orange : Colors.grey[700],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          
          // Page view
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemCount: _steps.length,
              itemBuilder: (context, index) {
                return SingleChildScrollView(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Header
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: _steps[index].color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Icon(
                          _steps[index].icon,
                          size: 40,
                          color: _steps[index].color,
                        ),
                      ),
                      SizedBox(height: 24),
                      
                      Text(
                        _steps[index].title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12),
                      
                      Text(
                        _steps[index].description,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[400],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 32),
                      
                      // Content
                      _steps[index].content,
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Navigation buttons
          Container(
            padding: EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button
                if (_currentPage > 0)
                  TextButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Text(
                      'Back',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  )
                else
                  SizedBox(width: 60),
                
                // Page indicator
                Text(
                  '${_currentPage + 1} / ${_steps.length}',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
                
                // Next button
                if (_currentPage < _steps.length - 1)
                  ElevatedButton(
                    onPressed: () {
                      _pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Next',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Done',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Welcome page content
  static Widget _buildWelcomePage() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color(0xFF21262D),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[800]!),
          ),
          child: Column(
            children: [
              Icon(Icons.security, color: Colors.orange, size: 40),
              SizedBox(height: 16),
              Text(
                'Kenapa Butuh Token?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'GitHub Personal Access Token memungkinkan aplikasi ini mengakses data commit kamu dengan aman tanpa perlu password.',
                style: TextStyle(color: Colors.grey[400]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        _buildInfoCard(
          'Aman & Pribadi',
          'Token hanya bisa digunakan untuk akses yang kamu izinkan',
          Icons.shield,
          Colors.green,
        ),
        SizedBox(height: 12),
        _buildInfoCard(
          'Mudah Dikelola',
          'Bisa dihapus atau diubah kapan saja dari GitHub',
          Icons.settings,
          Colors.blue,
        ),
      ],
    );
  }

  // Step 1 content
  static Widget _buildStep1() {
    return Column(
      children: [
        _buildInstructionCard([
          'Buka GitHub.com di browser',
          'Login ke akun GitHub kamu',
          'Klik foto profil di pojok kanan atas',
          'Pilih "Settings" dari dropdown menu',
        ]),
        SizedBox(height: 20),
        _buildVisualGuide(
          'assets/github_step1.png', // You would add this image
          'Klik foto profil → Settings',
        ),
      ],
    );
  }

  // Step 2 content
  static Widget _buildStep2() {
    return Column(
      children: [
        _buildInstructionCard([
          'Di halaman Settings, lihat sidebar kiri',
          'Scroll ke bawah sampai bagian paling bawah',
          'Cari dan klik "Developer settings"',
        ]),
        SizedBox(height: 20),
        _buildTipCard(
          'Tips: Developer settings ada di bagian paling bawah sidebar, setelah menu-menu lainnya.',
          Colors.blue,
        ),
      ],
    );
  }

  // Step 3 content
  static Widget _buildStep3() {
    return Column(
      children: [
        _buildInstructionCard([
          'Di halaman Developer settings',
          'Klik "Personal access tokens" di sidebar kiri',
          'Pilih "Tokens (classic)" - ini penting!',
        ]),
        SizedBox(height: 20),
        _buildWarningCard(
          'Penting: Pilih "Tokens (classic)", bukan yang "Fine-grained tokens"',
        ),
      ],
    );
  }

  // Step 4 content
  static Widget _buildStep4() {
    return Column(
      children: [
        _buildInstructionCard([
          'Klik tombol "Generate new token"',
          'Pilih "Generate new token (classic)"',
          'GitHub mungkin akan minta konfirmasi password',
        ]),
        SizedBox(height: 20),
        _buildTipCard(
          'Jika diminta password, masukkan password GitHub kamu untuk konfirmasi.',
          Colors.orange,
        ),
      ],
    );
  }

  // Step 5 content
  static Widget _buildStep5() {
    return Column(
      children: [
        _buildInstructionCard([
          'Note: Tulis "Flutter Streak App" atau nama lain',
          'Expiration: Pilih "No expiration" atau sesuai kebutuhan',
          'Scopes: Centang checkbox berikut ini:',
        ]),
        SizedBox(height: 16),
        _buildScopeCard(),
        SizedBox(height: 20),
        _buildWarningCard(
          'Pastikan scope "repo" dan "user" sudah dicentang, ini wajib untuk aplikasi berfungsi!',
        ),
      ],
    );
  }

  // Step 6 content
  static Widget _buildStep6() {
    return Column(
      children: [
        _buildInstructionCard([
          'Klik "Generate token" di bagian bawah',
          'Token akan muncul - COPY SEKARANG!',
          'Token hanya muncul sekali, jika hilang harus buat ulang',
        ]),
        SizedBox(height: 20),
        _buildTokenExample(),
        SizedBox(height: 20),
        _buildWarningCard(
          'PENTING: Simpan token di tempat yang aman. Jangan share ke siapa-siapa!',
        ),
      ],
    );
  }

  // Final page content
  static Widget _buildFinalPage() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color(0xFF21262D),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green[800]!),
          ),
          child: Column(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 60),
              SizedBox(height: 16),
              Text(
                'Token Siap Digunakan!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Sekarang kamu bisa kembali ke form login dan paste token yang sudah dibuat.',
                style: TextStyle(color: Colors.grey[400]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        _buildTipCard(
          'Jika token bermasalah, kamu bisa kembali ke tutorial ini kapan saja atau buat token baru.',
          Colors.blue,
        ),
      ],
    );
  }

  // Helper widgets
  static Widget _buildInstructionCard(List<String> steps) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF21262D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: steps.map((step) => Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• ',
                style: TextStyle(color: Colors.orange, fontSize: 16),
              ),
              Expanded(
                child: Text(
                  step,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  static Widget _buildInfoCard(String title, String description, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF21262D),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildTipCard(String tip, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb, color: color, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildWarningCard(String warning) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.red, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              warning,
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildScopeCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF21262D),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Scopes yang harus dicentang:',
            style: TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          _buildScopeItem('✅ repo', 'Full control of private repositories'),
          _buildScopeItem('✅ user', 'Update ALL user data'),
          _buildScopeItem('✅ read:user', 'Read ALL user profile data'),
        ],
      ),
    );
  }

  static Widget _buildScopeItem(String scope, String description) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            scope,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            description,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildTokenExample() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF21262D),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contoh Token:',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFF0D1117),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'ghp_1A2B3C4D5E6F7G8H9I0J1K2L3M4N5O6P7Q8R9S0T',
                    style: TextStyle(
                      color: Colors.green,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.copy, color: Colors.orange, size: 16),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(
                        text: 'ghp_1A2B3C4D5E6F7G8H9I0J1K2L3M4N5O6P7Q8R9S0T'));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildVisualGuide(String imagePath, String caption) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF21262D),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    height: 180,
                    width: double.infinity,
                  ),
              
                ],
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            caption,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Model for tutorial steps
class TutorialStep {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Widget content;

  TutorialStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.content,
  });
}

