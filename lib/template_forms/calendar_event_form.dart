import 'package:flutter/material.dart';

import 'package:aqr_lib/template_parsers.dart';
import 'package:aqr_lib/templates.dart';

import '../dummy/vertical_gap.dart';
import '../widgets/template_form.dart';

class CalendarEventForm extends TemplateForm<CalendarEventTemplate> {
  const CalendarEventForm({super.key, required super.onSubmit})
      : super(parser: const CalendarEventTemplateParser());

  @override
  State<CalendarEventForm> createState() => _CalendarEventFormState();
}

class _CalendarEventFormState extends TemplateFormState<CalendarEventForm> {
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
            const VerticalGap(),
            TextFormField(
              controller: summaryController,
              decoration: const InputDecoration(
                labelText: 'Summary',
                border: OutlineInputBorder(),
              ),
            ),
            const VerticalGap(),
            TextFormField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
            ),
            const VerticalGap(),
            TextFormField(
              controller: startDateController,
              decoration: const InputDecoration(
                labelText: 'Start Date',
                border: OutlineInputBorder(),
              ),
            ),
            const VerticalGap(),
            TextFormField(
              controller: endDateController,
              decoration: const InputDecoration(
                labelText: 'End Date',
                border: OutlineInputBorder(),
              ),
            ),
            const VerticalGap(),
            TextFormField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const VerticalGap(),
            TextFormField(
              controller: geoLatitudeController,
              decoration: const InputDecoration(
                labelText: 'Geo Latitude',
                border: OutlineInputBorder(),
              ),
            ),
            const VerticalGap(),
            TextFormField(
              controller: geoLongitudeController,
              decoration: const InputDecoration(
                labelText: 'Geo Longitude',
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
  }
}
