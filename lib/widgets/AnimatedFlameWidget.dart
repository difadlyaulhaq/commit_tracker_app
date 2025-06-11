import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedFlameWidget extends StatefulWidget {
  final dynamic streak;
  
  const AnimatedFlameWidget({Key? key, required this.streak}) : super(key: key);

  @override
  _AnimatedFlameWidgetState createState() => _AnimatedFlameWidgetState();
}

class _AnimatedFlameWidgetState extends State<AnimatedFlameWidget>
    with TickerProviderStateMixin {
  late AnimationController _fireController;
  late AnimationController _scaleController;
  late Animation<double> _fireAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Animasi untuk gerakan api
    _fireController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Animasi untuk scale berdasarkan streak
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fireAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fireController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    // Mulai animasi
    _fireController.repeat(reverse: true);
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fireController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_fireAnimation, _scaleAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value * _getScaleFromStreak(),
          child: Container(
            width: 200,
            height: 250,
            child: CustomPaint(
              painter: FlamePainter(
                animation: _fireAnimation.value,
                streak: widget.streak,
              ),
            ),
          ),
        );
      },
    );
  }
  
  // Scale api berdasarkan streak
  double _getScaleFromStreak() {
    int streakCount = _getStreakCount();
    if (streakCount >= 100) return 1.3;
    if (streakCount >= 50) return 1.2;
    if (streakCount >= 30) return 1.1;
    if (streakCount >= 10) return 1.0;
    return 0.9;
  }
  
  // Helper untuk mendapatkan nilai streak
  int _getStreakCount() {
    if (widget.streak is int) {
      return widget.streak as int;
    } else if (widget.streak != null) {
      // Coba berbagai kemungkinan property name untuk StreakModel
      if (widget.streak.currentStreak != null) {
        return widget.streak.currentStreak as int;
      } else if (widget.streak.streakCount != null) {
        return widget.streak.streakCount as int;
      } else if (widget.streak.dayCount != null) {
        return widget.streak.dayCount as int;
      } else if (widget.streak.count != null) {
        return widget.streak.count as int;
      }
    }
    return 0;
  }
}

class FlamePainter extends CustomPainter {
  final double animation;
  final dynamic streak;
  
  FlamePainter({required this.animation, required this.streak});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.8);
    
    // Warna api berdasarkan streak
    List<Color> flameColors = _getFlameColors();
    
    // Gambar multiple layers api untuk efek depth
    for (int i = 0; i < 3; i++) {
      _drawFlameLayer(canvas, center, size, i, flameColors);
    }
    
    // Gambar partikel api kecil
    _drawFireParticles(canvas, size);
    
    // Gambar glow effect
    _drawGlowEffect(canvas, center, size);
  }
  
  // Helper untuk mendapatkan nilai streak
  int _getStreakCount() {
    if (streak is int) {
      return streak as int;
    } else if (streak != null) {
      // Coba berbagai kemungkinan property name untuk StreakModel
      if (streak.currentStreak != null) {
        return streak.currentStreak as int;
      } else if (streak.streakCount != null) {
        return streak.streakCount as int;
      } else if (streak.dayCount != null) {
        return streak.dayCount as int;
      } else if (streak.count != null) {
        return streak.count as int;
      }
    }
    return 0;
  }
  
  List<Color> _getFlameColors() {
    int streakCount = _getStreakCount();
    if (streakCount >= 100) {
      // Api biru/putih untuk streak tinggi
      return [
        Color(0xFF00BFFF),
        Color(0xFF87CEEB),
        Color(0xFFFFFFFF),
      ];
    } else if (streakCount >= 50) {
      // Api ungu untuk streak menengah-tinggi
      return [
        Color(0xFFFF4500),
        Color(0xFFFF6347),
        Color(0xFFFFD700),
      ];
    } else if (streakCount >= 20) {
      // Api orange normal
      return [
        Color(0xFFFF4500),
        Color(0xFFFF8C00),
        Color(0xFFFFD700),
      ];
    } else {
      // Api merah untuk streak rendah
      return [
        Color(0xFFDC143C),
        Color(0xFFFF4500),
        Color(0xFFFF8C00),
      ];
    }
  }
  
  void _drawFlameLayer(Canvas canvas, Offset center, Size size, int layer, List<Color> colors) {
    final paint = Paint()
      ..color = colors[layer % colors.length].withOpacity(0.7 - layer * 0.2)
      ..style = PaintingStyle.fill;
    
    final path = Path();
    final baseWidth = 40.0 - layer * 8;
    final height = 120.0 + layer * 20;
    
    // Buat bentuk api dengan kurva bezier
    path.moveTo(center.dx, center.dy);
    
    // Sisi kiri api
    final leftControl1 = Offset(
      center.dx - baseWidth + math.sin(animation * 2 * math.pi + layer) * 8,
      center.dy - height * 0.3,
    );
    final leftControl2 = Offset(
      center.dx - baseWidth * 0.5 + math.cos(animation * 3 * math.pi + layer) * 12,
      center.dy - height * 0.7,
    );
    final topLeft = Offset(
      center.dx - 10 + math.sin(animation * 4 * math.pi + layer) * 15,
      center.dy - height + math.cos(animation * 2 * math.pi + layer) * 10,
    );
    
    path.quadraticBezierTo(leftControl1.dx, leftControl1.dy, leftControl2.dx, leftControl2.dy);
    path.quadraticBezierTo(leftControl2.dx, leftControl2.dy, topLeft.dx, topLeft.dy);
    
    // Puncak api
    final topCenter = Offset(
      center.dx + math.sin(animation * 3 * math.pi + layer) * 8,
      center.dy - height - 20 + math.cos(animation * 2 * math.pi + layer) * 8,
    );
    path.quadraticBezierTo(topLeft.dx, topLeft.dy, topCenter.dx, topCenter.dy);
    
    // Sisi kanan api
    final topRight = Offset(
      center.dx + 10 + math.cos(animation * 4 * math.pi + layer + math.pi) * 15,
      center.dy - height + math.sin(animation * 2 * math.pi + layer + math.pi) * 10,
    );
    final rightControl2 = Offset(
      center.dx + baseWidth * 0.5 + math.sin(animation * 3 * math.pi + layer + math.pi) * 12,
      center.dy - height * 0.7,
    );
    final rightControl1 = Offset(
      center.dx + baseWidth + math.cos(animation * 2 * math.pi + layer + math.pi) * 8,
      center.dy - height * 0.3,
    );
    
    path.quadraticBezierTo(topCenter.dx, topCenter.dy, topRight.dx, topRight.dy);
    path.quadraticBezierTo(topRight.dx, topRight.dy, rightControl2.dx, rightControl2.dy);
    path.quadraticBezierTo(rightControl2.dx, rightControl2.dy, rightControl1.dx, rightControl1.dy);
    path.quadraticBezierTo(rightControl1.dx, rightControl1.dy, center.dx, center.dy);
    
    canvas.drawPath(path, paint);
  }
  
  void _drawFireParticles(Canvas canvas, Size size) {
    final particlePaint = Paint()
      ..color = Colors.orange.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    
    final random = math.Random(42); // Seed tetap untuk konsistensi
    
    for (int i = 0; i < 20; i++) {
      final x = size.width * 0.3 + random.nextDouble() * size.width * 0.4;
      final y = size.height * 0.2 + random.nextDouble() * size.height * 0.6;
      final offset = Offset(
        x + math.sin(animation * 2 * math.pi + i) * 5,
        y + math.cos(animation * 3 * math.pi + i) * 3,
      );
      
      canvas.drawCircle(offset, 2 + random.nextDouble() * 3, particlePaint);
    }
  }
  
  void _drawGlowEffect(Canvas canvas, Offset center, Size size) {
    final glowPaint = Paint()
      ..color = Colors.orange.withOpacity(0.3)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 20);
    
    canvas.drawCircle(
      Offset(center.dx, center.dy - 60),
      60 + math.sin(animation * 2 * math.pi) * 10,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}