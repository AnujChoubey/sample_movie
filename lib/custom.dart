import 'package:flutter/material.dart';

class MovieTilePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.deepOrange
      ..style = PaintingStyle.fill;

    Path path = Path();
    // Create a complex shape resembling a stylized "bubble"
    path.moveTo(0, size.height * 0.20);
    // path.quadraticBezierTo(size.width * 0.10, size.height * 0.15, size.width * 0.25, size.height * 0.20);
    path.quadraticBezierTo(size.width * 0.30, size.height * 0.25, size.width * 0.35, size.height * 0.15);
    path.quadraticBezierTo(size.width * 0.40, 0, size.width * 0.50, 0);
    path.quadraticBezierTo(size.width * 0.60, 0, size.width * 0.65, size.height * 0.15);
    // path.quadraticBezierTo(size.width * 0.70, size.height * 0.25, size.width * 0.75, size.height * 0.20);
    // path.quadraticBezierTo(size.width * 0.90, size.height * 0.15, size.width, size.height * 0.20);
    path.lineTo(size.width, size.height * 0.80);
    path.quadraticBezierTo(size.width * 0.90, size.height * 0.85, size.width * 0.75, size.height * 0.80);
    path.quadraticBezierTo(size.width * 0.70, size.height * 0.75, size.width * 0.65, size.height * 0.85);
    path.quadraticBezierTo(size.width * 0.60, size.height, size.width * 0.50, size.height);
    path.quadraticBezierTo(size.width * 0.40, size.height, size.width * 0.35, size.height * 0.85);
    path.quadraticBezierTo(size.width * 0.30, size.height * 0.75, size.width * 0.25, size.height * 0.80);
    path.quadraticBezierTo(size.width * 0.10, size.height * 0.85, 0, size.height * 0.80);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class MovieTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CustomPaint(
          size: Size(350, 500), // Customize the size depending on your requirements
          painter: MovieTilePainter(),
        ),
      ),
    );
  }
}