import 'package:flutter/material.dart';

import 'package:aqr_lib/core.dart';
import 'package:aqr_lib/encoder.dart';
import 'package:reorderables/reorderables.dart';

import 'package:aqr_app/dummy/outlined_box_with_label.dart';
import 'package:aqr_app/widgets/segment_dialog.dart';

const modeToName = {
  Mode.numeric: 'Numeric',
  Mode.alphanumeric: 'Alphanumeric',
  Mode.byte: 'Byte',
  Mode.kanji: 'Kanji',
};

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

  @override
  Widget build(BuildContext context) {
    List<Widget> chips = List.generate(
      segments.length,
      (i) {
        final seg = segments[i];
        return GestureDetector(
          key: ValueKey(i),
          onTap: () => _editSegment(i),
          child: OutlinedBoxWithLabel(
            label: modeToName[seg.mode]!,
            child: Text(
              seg.content,
              softWrap: true,
            ),
          ),
        );
      },
    );

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
