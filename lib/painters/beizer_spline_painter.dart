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
    }
  }

  @override
  bool shouldRepaint(BeizerSplinePainter oldDelegate) => true;
}
