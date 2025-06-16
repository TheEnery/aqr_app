import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:aqr_app/dummy/outlined_box_with_label.dart';

class OutlinedTextWithLabel extends StatelessWidget {
  const OutlinedTextWithLabel({
    super.key,
    required this.text,
    required this.label,
  });

  final String text;
  final String label;

  @override
  Widget build(BuildContext context) {
    return OutlinedBoxWithLabel(
      label: label,
      child: FractionallySizedBox(
        widthFactor: 1.0,
        child: SelectableText(
          text,
          onTap: () => _copyToClipboard(context),
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }
}
