import 'package:flutter/material.dart';

class TemplateFormWrapper extends StatelessWidget {
  final String name;
  final Widget Function(BuildContext context) builder;

  const TemplateFormWrapper({
    super.key,
    required this.builder,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: builder(context),
      ),
    );
  }
}
