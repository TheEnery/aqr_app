import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:aqr_lib/templates.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:aqr_app/dummy/outlined_box_with_label.dart';
import 'package:aqr_app/pages/scanner_result_page.dart';

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
          OutlinedBoxWithLabel(
            label: 'URL',
            child: FractionallySizedBox(
              widthFactor: 1.0,
              child: SelectableText(
                template.url,
                onTap: () => _copyToClipboard(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: template.url));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('URL copied to clipboard')),
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
