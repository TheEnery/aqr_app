import 'package:flutter/material.dart';

import 'package:aqr_lib/core.dart';

import 'package:aqr_app/dummy/outlined_text_with_label.dart';
import 'package:aqr_app/dummy/vertical_gap.dart';

class ScannerResultPage extends StatelessWidget {
  final String title;
  final List<Widget> actions;
  final Widget child;
  final Template template;

  const ScannerResultPage({
    super.key,
    required this.title,
    required this.actions,
    required this.child,
    required this.template,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        actions: actions,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              child,
              const VerticalGap(),
              const Divider(),
              const VerticalGap(),
              OutlinedTextWithLabel(
                text: template.displayResult,
                label: 'Raw text',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
