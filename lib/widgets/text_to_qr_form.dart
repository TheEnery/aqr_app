import 'package:flutter/material.dart';

class TextToAqrForm extends StatefulWidget {
  const TextToAqrForm({super.key, required this.onSubmit});

  final Function(BuildContext, String) onSubmit;

  @override
  State<TextToAqrForm> createState() => _TextToAqrFormState();
}

class _TextToAqrFormState extends State<TextToAqrForm> {
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
            TextFormField(
              controller: textController,
              decoration: const InputDecoration(labelText: 'Text'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the text';
                }
                return null;
              },
            ),
            ElevatedButton(
              onPressed: () => widget.onSubmit(context, textController.text),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
