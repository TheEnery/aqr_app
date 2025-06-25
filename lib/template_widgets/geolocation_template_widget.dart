import 'package:flutter/material.dart';

import 'package:aqr_lib/templates.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';

import 'package:aqr_app/dummy/outlined_text_with_label.dart';
import 'package:aqr_app/dummy/vertical_gap.dart';
import 'package:aqr_app/pages/scanner_result_page.dart';

class GeolocationTemplateWidget extends StatelessWidget {
  final GeolocationTemplate template;

  const GeolocationTemplateWidget(this.template, {super.key});

  @override
  Widget build(BuildContext context) {
    return ScannerResultPage(
      title: 'Geolocation',
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          tooltip: 'Share',
          onPressed: _shareUrl,
        ),
      ],
      template: template,
      child: Column(
        children: [
          OutlinedTextWithLabel(
            text: template.latitude.toString(),
            label: 'Latitude',
          ),
          OutlinedTextWithLabel(
            text: template.longitude.toString(),
            label: 'Longitude',
          ),
          if (template.altitude != 0)
            OutlinedTextWithLabel(
                text: template.altitude.toString(), label: 'Altitude'),
          if (template.query != null && template.query!.isNotEmpty)
            OutlinedTextWithLabel(text: template.query!, label: 'Query'),
          const VerticalGap(),
          SizedBox(
            height: 500.0,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(template.latitude, template.longitude),
                initialZoom: 13,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(template.latitude, template.longitude),
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
    );
  }

  void _shareUrl() async {
    await SharePlus.instance
        .share(ShareParams(uri: Uri.parse(template.displayResult)));
  }
}
