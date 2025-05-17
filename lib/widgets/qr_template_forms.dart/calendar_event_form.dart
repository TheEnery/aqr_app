import 'package:flutter/material.dart';

import 'package:aqr/qr/qr_template_parsers/calendar_event_template_parser.dart';
import 'package:aqr/qr/qr_templates/calendar_event_template.dart';
import 'package:aqr/widgets/qr_template_form.dart';

class CalendarEventForm extends QrTemplateForm<CalendarEventTemplate> {
  const CalendarEventForm({super.key, required super.onSubmit})
      : super(parser: const CalendarEventTemplateParser());

  @override
  State<CalendarEventForm> createState() => _CalendarEventFormState();
}

class _CalendarEventFormState extends State<CalendarEventForm> {
  final summaryController = TextEditingController();
  final locationController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  final descriptionController = TextEditingController();
  final geoLatitudeController = TextEditingController();
  final geoLongitudeController = TextEditingController();

  @override
  void dispose() {
    summaryController.dispose();
    locationController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    descriptionController.dispose();
    geoLatitudeController.dispose();
    geoLongitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        child: Column(
          children: [
            TextFormField(
              controller: summaryController,
              decoration: const InputDecoration(labelText: 'Summary'),
            ),
            TextFormField(
              controller: locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            TextFormField(
              controller: startDateController,
              decoration: const InputDecoration(labelText: 'Start Date'),
            ),
            TextFormField(
              controller: endDateController,
              decoration: const InputDecoration(labelText: 'End Date'),
            ),
            TextFormField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextFormField(
              controller: geoLatitudeController,
              decoration: const InputDecoration(labelText: 'Geo Latitude'),
            ),
            TextFormField(
              controller: geoLongitudeController,
              decoration: const InputDecoration(labelText: 'Geo Longitude'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final template = CalendarEventTemplate(
                  summaryController.text,
                  startDateController.text,
                  endDateController.text,
                  null,
                  locationController.text,
                  null,
                  null,
                  descriptionController.text,
                  double.parse(geoLatitudeController.text),
                  double.parse(geoLongitudeController.text),
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
