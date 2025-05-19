import 'package:flutter/material.dart';

import 'package:aqr_lib/template_parsers.dart';
import 'package:aqr_lib/templates.dart';

import '../widgets/template_form.dart';

class GeolocationTemplateForm extends TemplateForm<GeolocationTemplate> {
  const GeolocationTemplateForm({super.key, required super.onSubmit})
      : super(parser: const GeolocationTemplateParser());

  @override
  State<GeolocationTemplateForm> createState() =>
      _GeolocationTemplateFormState();
}

class _GeolocationTemplateFormState extends State<GeolocationTemplateForm> {
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();
  final altitudeController = TextEditingController();
  final queryController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    latitudeController.dispose();
    longitudeController.dispose();
    altitudeController.dispose();
    queryController.dispose();
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
              controller: latitudeController,
              decoration: const InputDecoration(labelText: 'Latitude'),
            ),
            TextFormField(
              controller: longitudeController,
              decoration: const InputDecoration(labelText: 'Longitude'),
            ),
            TextFormField(
              controller: altitudeController,
              decoration: const InputDecoration(labelText: 'Altitude'),
            ),
            TextFormField(
              controller: queryController,
              decoration: const InputDecoration(labelText: 'Query'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final template = GeolocationTemplate(
                    double.parse(latitudeController.text),
                    double.parse(longitudeController.text),
                    double.parse(altitudeController.text),
                    queryController.text,
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
