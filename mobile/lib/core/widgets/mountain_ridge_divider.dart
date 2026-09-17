import 'package:flutter/material.dart';

/// The app's single recurring visual signature: a jagged ridge line
/// standing in for the standard straight hairline divider. Used once per
/// screen at most (e.g. under a hero image) — it's meant to be noticed,
/// not repeated everywhere.
class MountainRidgeDivider extends StatelessWidget {
  const MountainRidgeDivider({super.key, this.height = 28, this.color});

  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _RidgePainter(color ?? Theme.of(context).scaffoldBackgroundColor),
      ),
    );
  }
}

class _RidgePainter extends CustomPainter {
  _RidgePainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()..moveTo(0, size.height);
    final segment = size.width / 6;
    for (int i = 0; i <= 6; i++) {
      final x = segment * i;
      final y = i.isEven ? size.height * 0.15 : size.height * 0.75;
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _RidgePainter oldDelegate) => oldDelegate.color != color;
}
