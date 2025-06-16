import 'package:flutter/material.dart';

class OutlinedBoxWithLabel extends StatelessWidget {
  final String label;
  final Widget child;
  final EdgeInsets contentPadding;

  const OutlinedBoxWithLabel({
    super.key,
    required this.label,
    required this.child,
    this.contentPadding = const EdgeInsets.all(16.0),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final labelPainter = TextPainter(
          textDirection: TextDirection.ltr,
          text: TextSpan(text: label),
        )..layout();

        final labelWidth = labelPainter.width;
        final labelHeight = labelPainter.height;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: labelWidth + 28.0),
              child: Container(
                margin: EdgeInsets.symmetric(vertical: labelHeight / 2.0),
                padding: contentPadding,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: child,
              ),
            ),
            Positioned(
              left: 8.0,
              top: 0.0,
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  label,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
