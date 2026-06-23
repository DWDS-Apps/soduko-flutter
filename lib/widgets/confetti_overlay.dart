import 'dart:math';
import 'package:flutter/material.dart';

/// A confetti particle.
class _ConfettiPiece {
  double x;
  double y;
  final double speedY;
  final double speedX;
  final double size;
  final Color color;
  double rotation;
  double rotationSpeed;

  _ConfettiPiece({
    required this.x,
    required this.y,
    required this.speedY,
    required this.speedX,
    required this.size,
    required this.color,
    this.rotation = 0,
    this.rotationSpeed = 0,
  });
}

/// A simple confetti overlay that renders falling particles.
class ConfettiOverlay extends StatefulWidget {
  final int particleCount;
  final Duration duration;

  const ConfettiOverlay({
    super.key,
    this.particleCount = 40,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_ConfettiPiece> _particles;
  final _random = Random();

  static const _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.teal,
  ];

  @override
  void initState() {
    super.initState();
    _particles = List.generate(widget.particleCount, (_) {
      return _ConfettiPiece(
        x: _random.nextDouble(),
        y: -_random.nextDouble() * 0.5,
        speedY: 0.2 + _random.nextDouble() * 0.3,
        speedX: (_random.nextDouble() - 0.5) * 0.3,
        size: 4 + _random.nextDouble() * 6,
        color: _colors[_random.nextInt(_colors.length)],
        rotation: _random.nextDouble() * 6.28,
        rotationSpeed: (_random.nextDouble() - 0.5) * 0.2,
      );
    });

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _controller.value;
        // Update particle positions
        for (final p in _particles) {
          p.y += p.speedY * 0.02;
          p.x += p.speedX * 0.02;
          p.rotation += p.rotationSpeed * 0.1;
        }
        return CustomPaint(
          size: Size.infinite,
          painter: _ConfettiPainter(particles: _particles, progress: progress),
        );
      },
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiPiece> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final alpha = ((1 - progress) * 255).round().clamp(0, 255);
    for (final p in particles) {
      final paint = Paint()
        ..color = p.color.withValues(alpha: alpha / 255.0)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(p.x * size.width, p.y * size.height);
      canvas.rotate(p.rotation);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: p.size,
          height: p.size * 0.6,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => true;
}
