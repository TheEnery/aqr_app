import 'package:flutter/material.dart';

import 'package:aqr/qr/qr_template_parsers/sms_template_parser.dart';
import 'package:aqr/qr/qr_templates/sms_template.dart';
import 'package:aqr/widgets/qr_template_form.dart';

class SmsTemplateForm extends QrTemplateForm<SmsTemplate> {
  const SmsTemplateForm({super.key, required super.onSubmit})
      : super(parser: const SmsTemplateParser());

  @override
  State<SmsTemplateForm> createState() => _SmsFormState();
}

class _SmsFormState extends State<SmsTemplateForm> {
  final phoneNumberController = TextEditingController();
  final messageController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    phoneNumberController.dispose();
    messageController.dispose();
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
              controller: phoneNumberController,
              decoration: const InputDecoration(labelText: 'Phone number'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
            TextFormField(
              controller: messageController,
              decoration: const InputDecoration(labelText: 'Message'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final template = SmsTemplate(
                    [phoneNumberController.text],
                    null,
                    null,
                    messageController.text,
                  );
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
