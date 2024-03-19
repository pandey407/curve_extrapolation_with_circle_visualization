import 'package:curve_extrapolation_with_circle_visualization/node/node.dart';
import 'package:curve_extrapolation_with_circle_visualization/utils/canvas_ext.dart';
import 'package:curve_extrapolation_with_circle_visualization/utils/path_ext.dart';
import 'package:flutter/material.dart';
import 'package:proste_bezier_curve/proste_bezier_curve.dart';
import 'package:touchable/touchable.dart';

class BeizerSplinePainter extends CustomPainter {
  final BuildContext context;
  final List<Node> nodes;
  final void Function(int) nodeselectionChanged;

  final Animation<double> proofBallAnimation;
  final List<Offset> pointsOnCurve;
  final void Function(Offset) proofPositionUpdate;

  BeizerSplinePainter(
    this.context, {
    required this.nodes,
    required this.nodeselectionChanged,
    required this.proofBallAnimation,
    required this.pointsOnCurve,
    required this.proofPositionUpdate,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final touchyCanvas = TouchyCanvas(context, canvas);
    var boundingBox = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    var selectedNode = Paint()..color = Colors.blue;
    var node = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    var curve = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..blendMode = BlendMode.screen
      ..strokeCap = StrokeCap.round;
    var animatingProofBall = Paint()..color = Colors.orange.shade700;
    var regularProofBall = Paint()..color = Colors.orange.shade100;
    canvas.drawRect(rect, boundingBox);

    canvas.drawCirclesAlongPath(
        regularProofBall, pointsOnCurve, 10.0, nodes.last.position);

    List<double> x = [];
    List<double> y = [];

    for (var i = 0; i < nodes.length; i += 1) {
      final currentNode = nodes[i];

      touchyCanvas.drawCircle(
        currentNode.position,
        10,
        node,
        hitTestBehavior: HitTestBehavior.translucent,
        onTapDown: (details) {
          nodeselectionChanged(i);
        },
      );

      touchyCanvas.drawCircle(
        currentNode.position,
        5,
        selectedNode,
        hitTestBehavior: HitTestBehavior.translucent,
        onTapDown: (details) {
          nodeselectionChanged(i);
        },
      );
      final textSpan = TextSpan(
        text: "${i + 1}",
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      textPainter.paint(canvas, currentNode.position.translate(-5, 10));
      x.add(currentNode.position.dx);
      y.add(currentNode.position.dy);
    }
    final (px1, px2) = computeControlPoints(x);
    final (py1, py2) = computeControlPoints(y);
    var path = Path();
    path.moveTo(nodes.first.position.dx, nodes.first.position.dy);
    for (int i = 0; i < nodes.length - 1; i++) {
      ThirdOrderBezierCurveSection param = ThirdOrderBezierCurveSection(
        smooth: 0,
        p1: Offset(x[i], y[i]),
        p2: Offset(px1[i], py1[i]),
        p3: Offset(px2[i], py2[i]),
        p4: Offset(x[i + 1], y[i + 1]),
      );
      ThirdOrderBezierCurveDots dots =
          ProsteThirdOrderBezierCurve.calcCurveDots(param);

      path.cubicTo(dots.x1, dots.y1, dots.x2, dots.y2, dots.x3, dots.y3);
    }
    canvas.drawPath(path, curve);
    if (proofBallAnimation.status == AnimationStatus.forward) {
      final proofPosition =
          path.offsetAtProgress(progress: proofBallAnimation.value);
      proofPositionUpdate(proofPosition);
      canvas.drawCircle(
        proofPosition,
        10,
        animatingProofBall,
      );
    }
  }

  @override
  bool shouldRepaint(BeizerSplinePainter oldDelegate) => true;

  // Function to compute control points for a spline given a list of points
  (List<double>, List<double>) computeControlPoints(List<double> points) {
    // Determine the number of points
    final n = points.length - 1;

    // Initialize lists for control points
    List<double> p1 = List<double>.filled(n, 0.0);
    List<double> p2 = List<double>.filled(n, 0.0);
    // Initialize coefficient arrays for the tridiagonal matrix algorithm
    List<double> a = List<double>.filled(n, 0.0);
    List<double> b = List<double>.filled(n, 0.0);
    List<double> c = List<double>.filled(n, 0.0);
    List<double> r = List<double>.filled(n, 0.0);

    // Set up the edge conditions
    a[0] = 0;
    b[0] = 2;
    c[0] = 1;
    r[0] = points[0] + 2 * points[1];

    for (int i = 1; i < n - 1; i++) {
      a[i] = 1;
      b[i] = 4;
      c[i] = 1;
      r[i] = 4 * points[i] + 2 * points[i + 1];
    }

    a[n - 1] = 2;
    b[n - 1] = 7;
    c[n - 1] = 0;
    r[n - 1] = 8 * points[n - 1] + points[n];

    // Apply the tridiagonal matrix algorithm (Thomas Algorithm) to solve the linear system
    for (int i = 1; i < n; i++) {
      final m = a[i] / b[i - 1];
      b[i] -= m * c[i - 1];
      r[i] -= m * r[i - 1];
    }

    // Backward substitution to find the p1 values
    p1[n - 1] = r[n - 1] / b[n - 1];
    for (int i = n - 2; i >= 0; --i) {
      p1[i] = (r[i] - c[i] * p1[i + 1]) / b[i];
    }

    // Calculate the p2 values based on p1
    for (int i = 0; i < n - 1; i++) {
      p2[i] = 2 * points[i + 1] - p1[i + 1];
    }
    p2[n - 1] = 0.5 * (points[n] + p1[n - 1]);

    return (p1, p2);
  }
}
