import 'package:flutter/material.dart';

extension PathOffsetX on Path {
  Offset offsetAtProgress({required double progress}) {
    final pathMetrics = computeMetrics();
    final metrics = pathMetrics.toList();
    if (metrics.isEmpty) {
      return Offset.zero;
    }

    double animatedLength = metrics
            .map<double>((metric) => metric.length)
            .reduce((value, element) => value + element) *
        progress;

    for (final pathMetric in metrics) {
      if (animatedLength > pathMetric.length) {
        animatedLength -= pathMetric.length;
      } else {
        final pos = pathMetric.getTangentForOffset(animatedLength);
        return pos?.position ?? Offset.zero;
      }
    }

    return Offset.zero;
  }
}
