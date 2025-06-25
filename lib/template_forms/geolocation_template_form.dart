import 'package:flutter/material.dart';

import 'package:aqr_lib/template_parsers.dart';
import 'package:aqr_lib/templates.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../dummy/vertical_gap.dart';
import '../widgets/template_form.dart';

class GeolocationTemplateForm extends TemplateForm<GeolocationTemplate> {
  const GeolocationTemplateForm({super.key, required super.onSubmit})
      : super(parser: const GeolocationTemplateParser());

  @override
  State<GeolocationTemplateForm> createState() =>
      _GeolocationTemplateFormState();
}

class _GeolocationTemplateFormState
    extends TemplateFormState<GeolocationTemplateForm> {
  final latitudeController = TextEditingController()..text = '49.8360';
  final longitudeController = TextEditingController()..text = '24.0145';
  final altitudeController = TextEditingController();
  final queryController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final mapController = MapController();

  set position(LatLng ll) {
    setState(() {
      latitudeController.text = ll.latitude.toString();
      longitudeController.text = ll.longitude.toString();
    });
  }

  LatLng get position {
    return LatLng(
      double.tryParse(latitudeController.text) ?? 0.0,
      double.tryParse(longitudeController.text) ?? 0.0,
    );
  }

  void updateMapCenter() {
    mapController.move(position, 13);
  }

  @override
  void dispose() {
    latitudeController.dispose();
    longitudeController.dispose();
    altitudeController.dispose();
    queryController.dispose();
    mapController.dispose();

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
              controller: latitudeController,
              decoration: const InputDecoration(
                labelText: 'Latitude',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  setState(updateMapCenter);
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the latitude';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter the valid value';
                }
                return null;
              },
            ),
            const VerticalGap(),
            TextFormField(
              controller: longitudeController,
              decoration: const InputDecoration(
                labelText: 'Longitude',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  setState(updateMapCenter);
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the longitude';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter the valid value';
                }
                return null;
              },
            ),
            const VerticalGap(),
            TextFormField(
              controller: altitudeController,
              decoration: const InputDecoration(
                labelText: 'Altitude',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value != null &&
                    value.isNotEmpty &&
                    double.tryParse(value) == null) {
                  return 'Please enter the valid value';
                }
                return null;
              },
            ),
            const VerticalGap(),
            TextFormField(
              controller: queryController,
              decoration: const InputDecoration(
                labelText: 'Query',
                border: OutlineInputBorder(),
              ),
            ),
            const VerticalGap(),
            SizedBox(
              height: 500.0,
              child: FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: position,
                  initialZoom: 13,
                  onTap: (tapPosition, latlng) {
                    position = latlng;
                  },
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: position,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
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
      final template = GeolocationTemplate(
        double.parse(latitudeController.text),
        double.parse(longitudeController.text),
        (altitudeController.text.isNotEmpty)
            ? double.parse(altitudeController.text)
            : 0,
        queryController.text,
      );
      widget.onSubmit(context, template);
    }
  }
}
