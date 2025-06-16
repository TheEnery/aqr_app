import 'package:flutter/material.dart';

import 'package:aqr_lib/core.dart';

import 'package:aqr_app/pages/constructor_page.dart';

class SegmentDialog extends StatefulWidget {
  final String content;
  final Mode mode;
  final void Function(String content, Mode mode) onConfirm;
  final String title;

  const SegmentDialog({
    super.key,
    this.content = '',
    this.mode = Mode.byte,
    required this.onConfirm,
    required this.title,
  });

  @override
  State<SegmentDialog> createState() => _SegmentDialogState();
}

class _SegmentDialogState extends State<SegmentDialog> {
  late String content;
  late Mode mode;
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    content = widget.content;
    mode = widget.mode;
    controller = TextEditingController(text: content);
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField(
            decoration: const InputDecoration(
              labelText: 'Mode',
            ),
            value: mode,
            items: modeToName.entries
                .map((m) => DropdownMenuItem(
                      value: m.key,
                      child: Text(m.value),
                    ))
                .toList(),
            onChanged: (m) => setState(() => mode = m!),
          ),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Content',
              errorText: validate(controller.text, mode),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            widget.onConfirm(controller.text, mode);
            Navigator.pop(context);
          },
          child: const Text('OK'),
        ),
      ],
    );
  }

  String? validate(String value, Mode mode) {
    switch (mode) {
      case Mode.numeric:
        return RegExp(r'^\d*$').hasMatch(value)
            ? null
            : 'Only digits are allowed';
      case Mode.alphanumeric:
        return RegExp(r'^[0-9A-Z \$%\*\+\-\.\/\:]*$').hasMatch(value)
            ? null
            : 'Only 0-9, A-Z and ␣\$%*+-./: are allowed';
      case Mode.byte:
        return null;
      case Mode.kanji:
        return value.runes.every((r) => r > 0x800)
            ? null
            : 'Only Kanji characters are allowed';
      default:
        throw StateError('Unsupported mode');
    }
  }
}
