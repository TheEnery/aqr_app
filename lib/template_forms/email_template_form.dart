import 'package:flutter/material.dart';

import 'package:aqr_lib/template_parsers.dart';
import 'package:aqr_lib/templates.dart';

import '../dummy/vertical_gap.dart';
import '../widgets/template_form.dart';

class EmailTemplateForm extends TemplateForm<EmailTemplate> {
  const EmailTemplateForm({super.key, required super.onSubmit})
      : super(parser: const EmailTemplateParser());

  @override
  State<EmailTemplateForm> createState() => _EmailTemplateFormState();
}

class _EmailTemplateFormState extends State<EmailTemplateForm> {
  static const emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

  final emailController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
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
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!(RegExp(emailPattern).hasMatch(value))) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            const VerticalGap(16),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final template = EmailTemplate(emailController.text);
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
