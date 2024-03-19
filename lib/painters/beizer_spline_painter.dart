import 'package:curve_extrapolation_with_circle_visualization/node/node.dart';
import 'package:flutter/material.dart';
import 'package:touchable/touchable.dart';

class BeizerSplinePainter extends CustomPainter {
  final BuildContext context;
  final List<Node> nodes;

  final void Function(int) nodeselectionChanged;

  BeizerSplinePainter(
    this.context, {
    required this.nodes,
    required this.nodeselectionChanged,
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

    canvas.drawRect(rect, boundingBox);

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
      x.add(currentNode.position.dx);
      y.add(currentNode.position.dy);
    }
    final (px1, px2) = computeControlPoints(x);
    final (py1, py2) = computeControlPoints(y);

    canvas.drawCircle(Offset(px1[0], py1[0]), 3, Paint()..color = Colors.red);
    canvas.drawCircle(Offset(px2[0], py2[0]), 3, Paint()..color = Colors.red);
  }

  @override
  bool shouldRepaint(BeizerSplinePainter oldDelegate) => true;

  // Function to compute control points for a spline section
  (List<double>, List<double>) computeControlPoints(List<double> points) {
    final n = points.length - 1;
    // Initialize lists for control points
    final p1 = List<double>.filled(n, 0.0);
    final p2 = List<double>.filled(n, 0.0);

    // Initialize coefficient arrays for the tridiagonal matrix algorithm
    final a = List<double>.filled(n, 1.0);
    final b = List<double>.filled(n, 4.0);
    final c = List<double>.filled(n, 1.0);
    final r = List<double>.filled(n, 0.0);

    // Compute the r values based on the input points
    r[0] = points[0] + 2 * points[1];
    for (int i = 1; i < n - 1; i++) {
      r[i] = 4 * points[i] + 2 * points[i + 1];
    }
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
