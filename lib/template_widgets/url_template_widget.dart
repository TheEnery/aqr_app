import 'package:flutter/material.dart';

import 'package:aqr_lib/templates.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:aqr_app/pages/scanner_result_page.dart';

import '../dummy/outlined_text_with_label.dart';

class UrlTemplateWidget extends StatelessWidget {
  final UrlTemplate template;

  const UrlTemplateWidget(this.template, {super.key});

  @override
  Widget build(BuildContext context) {
    return ScannerResultPage(
      title: 'URL',
      actions: [
        IconButton(
          icon: const Icon(Icons.open_in_new, size: 20),
          tooltip: 'Open',
          onPressed: _launchUrl,
        ),
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
            label: 'URL',
            text: template.displayResult,
          ),
        ],
      ),
    );
  }

  void _launchUrl() async {
    final Uri uri = Uri.parse(template.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _shareUrl() async {
    await SharePlus.instance.share(ShareParams(uri: Uri.parse(template.url)));
  }
}
