import 'package:flutter/material.dart';
import '../models/streak_model.dart';

class FlameWidget extends StatefulWidget {
  final StreakModel streak;

  FlameWidget({required this.streak});

  @override
  _FlameWidgetState createState() => _FlameWidgetState();
}

class _FlameWidgetState extends State<FlameWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: -0.1,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.streak.hasCommittedToday) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.streak.getFlameColor();
    final size = _getFlameSize();

    return Container(
      height: 200,
      child: Column(
        children: [
          if (widget.streak.hasCommittedToday)
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Transform.rotate(
                    angle: _rotationAnimation.value,
                    child: _buildFlame(color, size),
                  ),
                );
              },
            )
          else
            _buildFlame(color, size),
          SizedBox(height: 16),
          Text(
            widget.streak.hasCommittedToday ? 'Streak Active!' : 'No Commit Today',
            style: TextStyle(
              color: widget.streak.hasCommittedToday ? Colors.orange : Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlame(Color color, double size) {
    return Container(
      width: size,
      height: size,
      child: CustomPaint(
        painter: FlamePainter(color: color),
      ),
    );
  }

  double _getFlameSize() {
    final commits = widget.streak.totalCommits;
    if (commits >= 1000) return 120;
    if (commits >= 500) return 100;
    if (commits >= 200) return 90;
    return 80;
  }
}

class FlamePainter extends CustomPainter {
  final Color color;

  FlamePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final gradient = RadialGradient(
      colors: [
        color.withOpacity(0.8),
        color.withOpacity(0.4),
        color.withOpacity(0.1),
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    paint.shader = gradient;

    final path = Path();
    
    // Create flame shape
    path.moveTo(size.width * 0.5, size.height * 0.9);
    path.quadraticBezierTo(
      size.width * 0.2, size.height * 0.7,
      size.width * 0.3, size.height * 0.4,
    );
    path.quadraticBezierTo(
      size.width * 0.1, size.height * 0.2,
      size.width * 0.4, size.height * 0.1,
    );
    path.quadraticBezierTo(
      size.width * 0.5, size.height * 0.05,
      size.width * 0.6, size.height * 0.1,
    );
    path.quadraticBezierTo(
      size.width * 0.9, size.height * 0.2,
      size.width * 0.7, size.height * 0.4,
    );
    path.quadraticBezierTo(
      size.width * 0.8, size.height * 0.7,
      size.width * 0.5, size.height * 0.9,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
