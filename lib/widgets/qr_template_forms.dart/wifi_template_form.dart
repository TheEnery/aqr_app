import 'package:flutter/material.dart';

import 'package:aqr/qr/qr_template_parsers/wifi_template_parser.dart';
import 'package:aqr/qr/qr_templates/wifi_template.dart';
import 'package:aqr/widgets/dummy/vertical_gap.dart';
import 'package:aqr/widgets/qr_template_form.dart';

class WifiTemplateForm extends QrTemplateForm<WifiTemplate> {
  const WifiTemplateForm({super.key, required super.onSubmit})
      : super(parser: const WifiTemplateParser());

  @override
  State<WifiTemplateForm> createState() => _WifiTemplateFormState();
}

class _WifiTemplateFormState extends State<WifiTemplateForm> {
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
              decoration: const InputDecoration(labelText: 'Type'),
            ),
            TextFormField(
              controller: ssidController,
              decoration: const InputDecoration(labelText: 'SSID'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the SSID';
                }
                return null;
              },
            ),
            TextFormField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            CheckboxListTile(
              value: hiddenValue,
              onChanged: (value) =>
                  setState(() => hiddenValue = value ?? false),
              title: const Text('Hidden'),
              contentPadding: const EdgeInsets.all(0.0),
            ),
            const VerticalGap(16),
            ElevatedButton(
              onPressed: () {
                final template = WifiTemplate(
                  ssidController.text,
                  passwordController.text,
                  typeOption,
                  hiddenValue,
                );
                widget.onSubmit(context, template);
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
