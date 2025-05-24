import 'package:flutter/material.dart';

import 'package:aqr_lib/core.dart';
import 'package:aqr_lib/encoder.dart';
import 'package:reorderables/reorderables.dart';

class ConstructorPage extends StatefulWidget {
  final void Function(BuildContext context, List<Segment> segments) onSubmit;

  const ConstructorPage({super.key, required this.onSubmit});

  @override
  State<ConstructorPage> createState() => _ConstructorPageState();
}

class _ConstructorPageState extends State<ConstructorPage> {
  List<Segment> segments = [];

  void _addSegment() {
    showDialog(
      context: context,
      builder: (_) => SegmentDialog(
        onConfirm: (content, mode) {
          setState(() => segments.add(Segment(content: content, mode: mode)));
        },
        title: 'Add segment',
      ),
    );
  }

  void _editSegment(int index) {
    final seg = segments[index];
    showDialog(
      context: context,
      builder: (_) => SegmentDialog(
        content: seg.content,
        mode: seg.mode,
        onConfirm: (content, mode) {
          setState(() {
            seg.content = content;
            seg.mode = mode;
          });
        },
        title: 'Edit segment',
      ),
    );
  }

  static const modeToName = {
    Mode.numeric: 'Numeric',
    Mode.alphanumeric: 'Alphanumeric',
    Mode.byte: 'Byte',
    Mode.kanji: 'Kanji',
  };

  @override
  Widget build(BuildContext context) {
    List<Widget> chips = List.generate(segments.length, (i) {
      final seg = segments[i];
      return GestureDetector(
        key: ValueKey(i),
        onTap: () => _editSegment(i),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.green),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                modeToName[seg.mode]!,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                seg.content,
                softWrap: true,
              ),
            ],
          ),
        ),
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Constructor'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              widget.onSubmit(
                context,
                segments,
              );
            },
          )
        ],
      ),
      body: Builder(builder: (context) {
        if (segments.isEmpty) {
          return const Center(
            child: Text(
              'Tap the + button to add a segment.',
              textAlign: TextAlign.center,
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: ReorderableWrap(
            spacing: 8,
            runSpacing: 8,
            children: chips,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                final item = segments.removeAt(oldIndex);
                segments.insert(newIndex, item);
              });
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSegment,
        child: const Icon(Icons.add),
      ),
    );
  }
}

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
            items: _ConstructorPageState.modeToName.entries
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
