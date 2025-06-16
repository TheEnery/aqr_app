import 'package:flutter/material.dart';

class VerticalGap extends StatelessWidget {
  final double height;

  const VerticalGap({super.key, this.height = 16.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height);
  }
}
