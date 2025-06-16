import 'package:flutter/material.dart';

import 'package:aqr_app/dummy/vertical_gap.dart';
import 'package:aqr_app/widgets/template_form.dart';

class TextToAqrForm extends StatefulWidget {
  const TextToAqrForm({super.key, required this.onSubmit});

  final Function(BuildContext, String) onSubmit;

  @override
  State<TextToAqrForm> createState() => _TextToAqrFormState();
}

class _TextToAqrFormState extends TemplateFormState<TextToAqrForm> {
  final textController = TextEditingController();

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        child: Column(
          children: [
            const VerticalGap(),
            TextFormField(
              controller: textController,
              decoration: const InputDecoration(
                labelText: 'Some characters to encode',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              minLines: 3,
              maxLines: 20,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void submit() {
    widget.onSubmit(context, textController.text);
  }
}
