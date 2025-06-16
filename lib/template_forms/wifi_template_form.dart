import 'package:flutter/material.dart';

import 'package:aqr_lib/template_parsers.dart';
import 'package:aqr_lib/templates.dart';

import '../dummy/vertical_gap.dart';
import '../widgets/template_form.dart';

class WifiTemplateForm extends TemplateForm<WifiTemplate> {
  const WifiTemplateForm({super.key, required super.onSubmit})
      : super(parser: const WifiTemplateParser());

  @override
  State<WifiTemplateForm> createState() => _WifiTemplateFormState();
}

class _WifiTemplateFormState extends TemplateFormState<WifiTemplateForm> {
  static const typeOptions = [
    'None',
    'WEP',
    'WPA',
    'WPA2',
  ];

  final ssidController = TextEditingController();
  final passwordController = TextEditingController();
  bool hiddenValue = false;
  String typeOption = typeOptions[0];

  @override
  void dispose() {
    ssidController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        child: Column(
          children: [
            const VerticalGap(),
            DropdownButtonFormField(
              items: typeOptions
                  .map((o) => DropdownMenuItem(
                        value: o,
                        child: Text(o),
                      ))
                  .toList(),
              onChanged: (o) =>
                  setState(() => typeOption = o ?? typeOptions[0]),
              value: typeOption,
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
              ),
            ),
            const VerticalGap(),
            TextFormField(
              controller: ssidController,
              decoration: const InputDecoration(
                labelText: 'SSID',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the SSID';
                }
                return null;
              },
            ),
            const VerticalGap(),
            TextFormField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const VerticalGap(),
            CheckboxListTile(
              value: hiddenValue,
              shape: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[500]!)),
              onChanged: (value) =>
                  setState(() => hiddenValue = value ?? false),
              title: const Text('Hidden'),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0.0, horizontal: 12.0),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void submit() {
    final template = WifiTemplate(
      ssidController.text,
      passwordController.text,
      typeOption,
      hiddenValue,
    );
    widget.onSubmit(context, template);
  }
}
