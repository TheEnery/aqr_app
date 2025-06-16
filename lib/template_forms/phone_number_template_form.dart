import 'package:flutter/material.dart';

import 'package:aqr_lib/template_parsers.dart';
import 'package:aqr_lib/templates.dart';

import 'package:aqr_app/dummy/vertical_gap.dart';

import '../widgets/template_form.dart';

class PhoneNumberTemplateForm extends TemplateForm<PhoneNumberTemplate> {
  const PhoneNumberTemplateForm({super.key, required super.onSubmit})
      : super(parser: const PhoneNumberTemplateParser());

  @override
  State<PhoneNumberTemplateForm> createState() =>
      _PhoneNumberTemplateFormState();
}

class _PhoneNumberTemplateFormState
    extends TemplateFormState<PhoneNumberTemplateForm> {
  final phoneNumberController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: formKey,
        child: Column(
          children: [
            const VerticalGap(),
            TextFormField(
              controller: phoneNumberController,
              decoration: const InputDecoration(
                labelText: 'Phone number',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void submit() {
    if (formKey.currentState!.validate()) {
      final template =
          PhoneNumberTemplate(phoneNumberController.text, null, null);
      widget.onSubmit(context, template);
    }
  }
}
