import 'dart:math' as math;
import 'package:flutter/material.dart';


void main() {

  runApp(RadarWidget());
}

typedef TargetPosition = ({double radian, double distance});

class RenderingSet {
  final double radius = 150;
  double get diameter => radius*2;

  final Color lineColor = const Color(0xFF69B428);
  final Color sweeperColor = const Color(0xFF35FF2E);
  final Color sweeperGradientColor = const Color(0x3235FF2E);
}

class RadarWidget extends StatefulWidget {
  const RadarWidget({super.key});

  @override
  State<RadarWidget> createState() => _RadarWidgetState();
}

class _RadarWidgetState extends State<RadarWidget> with SingleTickerProviderStateMixin{

  late final AnimationController _controller;
  late List<TargetPosition> _objects;
  final set = RenderingSet();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 5000),
        upperBound: math.pi * 2
    );
    _generateObjects();
    _controller.repeat();
  }


  // 랜덤으로 생성
  void _generateObjects() {
    final random = math.Random();
    // 5 - 10
    _objects = List.generate(5 + random.nextInt(5), (i) {
      return (
      radian: math.pi * 2 * random.nextDouble(),
      distance: 30.0 + random.nextInt(100)
      );
    });
  }


  @override
  Widget build(BuildContext context) {

    return Material(
      color: Colors.black,
      child: CustomPaint(
        size: Size.fromRadius(set.radius),
        painter: _RadarPainter(_controller, _objects, set),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}


class _RadarPainter extends CustomPainter {

  final Animation<double> animation;
  final List<TargetPosition> targets;
  final RenderingSet set;

  _RadarPainter(this.animation, this.targets, this.set) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width/2, size.height/2);

    _drawLine(canvas, size, center);
    _drawSweeper(canvas, size, center);
    _drawTarget(canvas, size, center);
  }

  void _drawTarget(Canvas canvas, Size size, Offset center) {
    final detectionRange = 0.2;
    for (int i = 0; i < targets.length; i++) {
      final t = targets[i];

      // double a = animation.value % (2 * math.pi);
      double a = animation.value;
      double b = t.radian % (2 * math.pi);

      double diff = (a - b) / (2 * math.pi);
      if (diff < 0) diff += 1;
      if (diff > detectionRange) continue;

      final v = -((diff - 0.1).abs()) * 10 + 1;
      final alpha = (255 * v).toInt().clamp(0, 255);

      final x = math.cos(t.radian) * t.distance;
      final y = math.sin(t.radian) * t.distance;
      final pos = center.translate(x, y);

      canvas.drawCircle(pos, 6.0, Paint()..color = set.sweeperColor.withAlpha(alpha));
    }
  }

  void _drawSweeper(Canvas canvas, Size size, Offset center) {
    // 360 * 1/10
    final sweepAngle = math.pi/5;

    final toX = set.radius * math.cos(animation.value);
    final toY = set.radius * math.sin(animation.value);

    final path = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(toX, toY)
      ..arcTo(Rect.fromCircle(center: center, radius: set.radius), animation.value - sweepAngle, sweepAngle, true)
      ..lineTo(center.dx, center.dy);

    final paint = Paint()
      ..shader = SweepGradient(
          colors: [
            set.sweeperGradientColor, set.sweeperColor
          ],
          startAngle: animation.value - sweepAngle,
          endAngle: animation.value,
          tileMode: TileMode.mirror
      ).createShader(Rect.fromCircle(center: center, radius: set.diameter));

    canvas.drawPath(path, paint);
  }

  void _drawLine(Canvas canvas, Size size, Offset center) {
    final painter = Paint()..color=set.lineColor..style=PaintingStyle.stroke..strokeWidth=2;

    for(int i=1; i<=4; i++) {
      canvas.drawCircle(
          center,
          set.radius * i/4,
          painter
      );
    }

    canvas.drawLine(
        Offset(center.dx - set.radius, center.dy),
        Offset(center.dx + set.radius, center.dy),
        painter
    );
    canvas.drawLine(
        Offset(center.dx, center.dy - set.radius),
        Offset(center.dx, center.dy + set.radius),
        painter
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
