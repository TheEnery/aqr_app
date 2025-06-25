import 'package:flutter/material.dart';

import 'package:aqr_lib/templates.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:aqr_app/dummy/outlined_text_with_label.dart';
import 'package:aqr_app/pages/scanner_result_page.dart';

class EmailTemplateWidget extends StatelessWidget {
  final EmailTemplate template;

  const EmailTemplateWidget(this.template, {super.key});

  @override
  Widget build(BuildContext context) {
    return ScannerResultPage(
      title: 'Email',
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
          if (template.tos != null)
            OutlinedTextWithLabel(label: 'To', text: template.tos!.join(', ')),
          if (template.ccs != null)
            OutlinedTextWithLabel(label: 'CC', text: template.ccs!.join(', ')),
          if (template.bccs != null)
            OutlinedTextWithLabel(
                label: 'BCC', text: template.bccs!.join(', ')),
          if (template.subject != null)
            OutlinedTextWithLabel(label: 'Subject', text: template.subject!),
          if (template.body != null)
            OutlinedTextWithLabel(label: 'Body', text: template.body!),
        ],
      ),
    );
  }

  void _launchUrl() async {
    final uri = Uri.parse('mailto:${template.tos?.join(',') ?? ' '}'
        '?subject=${template.subject ?? ' '}'
        '&body=${template.body ?? ' '}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _shareUrl() async {
    await SharePlus.instance.share(ShareParams(text: template.displayResult));
  }
}
