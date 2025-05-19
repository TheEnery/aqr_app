import 'package:flutter/material.dart';

import 'package:aqr_lib/template_parsers.dart';
import 'package:aqr_lib/templates.dart';

import '../dummy/vertical_gap.dart';
import '../widgets/template_form.dart';

class UrlTemplateForm extends TemplateForm<UrlTemplate> {
  const UrlTemplateForm({super.key, required super.onSubmit})
      : super(parser: const UrlTemplateParser());

  @override
  State<UrlTemplateForm> createState() => _UrlTemplateFormState();
}

class _UrlTemplateFormState extends State<UrlTemplateForm> {
  final urlController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: formKey,
        child: Column(
          children: [
            TextFormField(
              controller: urlController,
              decoration: const InputDecoration(labelText: 'URL'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your URL';
                }
                return null;
              },
            ),
            const VerticalGap(16),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final template = UrlTemplate(urlController.text);
                  widget.onSubmit(context, template);
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
