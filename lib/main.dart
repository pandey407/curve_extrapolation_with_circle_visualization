import 'package:curve_extrapolation_with_circle_visualization/node/node.dart';
import 'package:curve_extrapolation_with_circle_visualization/painters/beizer_spline_painter.dart';
import 'package:flutter/material.dart';
import 'package:touchable/touchable.dart';

void main() {
  runApp(const AppLauncher());
}

class AppLauncher extends StatelessWidget {
  const AppLauncher({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Curve Extrapolation and Circle Visualizatio',
      home: CurveExtrapolationVisualization(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CurveExtrapolationVisualization extends StatefulWidget {
  const CurveExtrapolationVisualization({super.key});

  @override
  State<CurveExtrapolationVisualization> createState() =>
      _CurveExtrapolationVisualizationState();
}

class _CurveExtrapolationVisualizationState
    extends State<CurveExtrapolationVisualization> {
  late List<Node> nodes;
  int selectedNodeIndex = 0;

  @override
  void initState() {
    super.initState();
    nodes = List.generate(
      5,
      (index) => Node(
        Offset(40 + (index + 1) * 20, 30 + (index + 1) * 10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              color: Colors.grey,
              height: MediaQuery.of(context).size.height * 0.3,
              width: MediaQuery.of(context).size.width,
              child: GestureDetector(
                onPanUpdate: (details) {
                  Offset tapPosition = details.localPosition;
                  tapPosition = Offset(
                    tapPosition.dx
                        .clamp(0.0, MediaQuery.of(context).size.width - 32),
                    tapPosition.dy
                        .clamp(0.0, MediaQuery.of(context).size.height * 0.3),
                  );
                  Node toMove = nodes[selectedNodeIndex];
                  toMove.updatePosition(tapPosition.dx, tapPosition.dy);
                  setState(() {});
                },
                child: CanvasTouchDetector(
                  gesturesToOverride: const [
                    GestureType.onTapDown,
                    GestureType.onTapUp,
                  ],
                  builder: (touchyCtx) => CustomPaint(
                    painter: BeizerSplinePainter(
                      touchyCtx,
                      nodes: nodes,
                      nodeselectionChanged: (index) {
                        setState(() {
                          selectedNodeIndex = index;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
