import 'package:flutter/material.dart';

import 'package:aqr_lib/core.dart';
import 'package:aqr_lib/decoder.dart';
import 'package:aqr_lib/templates.dart';
import 'package:share_plus/share_plus.dart';

import 'package:aqr_app/template_widgets/email_template_widget.dart';
import 'package:aqr_app/template_widgets/geolocation_template_widget.dart';
import 'package:aqr_app/template_widgets/url_template_widget.dart';

class ScannerResultPageWrapper extends StatelessWidget {
  ScannerResultPageWrapper({super.key, required this.result}) {
    template = TemplateManager().parse(result.text);
  }

  final DecoderResult result;
  late final Template? template;

  @override
  Widget build(BuildContext context) {
    return Builder(builder: _getResultWidget);
  }

  Widget _getResultWidget(BuildContext context) {
    return switch (template) {
      EmailTemplate t => EmailTemplateWidget(t),
      GeolocationTemplate t => GeolocationTemplateWidget(t),
      UrlTemplate t => UrlTemplateWidget(t),
      Template _ => throw UnimplementedError(),
      null => TextResultWidget(result: result),
    };
  }
}

class TextResultWidget extends StatelessWidget {
  const TextResultWidget({
    super.key,
    required this.result,
  });

  final DecoderResult result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Text'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share',
            onPressed: _share,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: SelectableText(
              result.text,
              maxLines: null,
            ),
          ),
        ),
      ),
    );
  }

  void _share() async {
    await SharePlus.instance.share(ShareParams(text: result.text));
  }
}
