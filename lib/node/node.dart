// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class Node {
  Offset position;
  Node(
    this.position,
  ) {
    position = position;
  }

  void updatePosition(x, y) {
    position = Offset(x, y);
  }
}
