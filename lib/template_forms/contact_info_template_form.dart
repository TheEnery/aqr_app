import 'package:flutter/material.dart';

import 'package:aqr_lib/template_parsers.dart';
import 'package:aqr_lib/templates.dart';

import '../dummy/vertical_gap.dart';
import '../widgets/template_form.dart';

class ContactInfoTemplateForm extends TemplateForm<ContactInfoTemplate> {
  const ContactInfoTemplateForm({super.key, required super.onSubmit})
      : super(parser: const ContactInfoTemplateParser());

  @override
  State<ContactInfoTemplateForm> createState() =>
      _ContactInfoTemplateFormState();
}

class _ContactInfoTemplateFormState
    extends TemplateFormState<ContactInfoTemplateForm> {
  final nameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final noteController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameController.dispose();
    phoneNumberController.dispose();
    emailController.dispose();
    addressController.dispose();
    noteController.dispose();
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
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const VerticalGap(),
            TextFormField(
              controller: phoneNumberController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
            ),
            const VerticalGap(),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const VerticalGap(),
            TextFormField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
            ),
            const VerticalGap(),
            TextFormField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'Note',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void submit() {
    if (formKey.currentState!.validate()) {
      final template = ContactInfoTemplate(
        names: [nameController.text],
        phoneNumbers: [phoneNumberController.text],
        emails: [emailController.text],
        note: noteController.text,
        addresses: [addressController.text],
      );
      widget.onSubmit(context, template);
    }
  }
}
