import 'package:flutter/material.dart';

import 'package:aqr_lib/templates.dart';

import 'package:aqr_app/pages/scanner_result_page.dart';

class EmailTemplateWidget extends StatelessWidget {
  final EmailTemplate template;

  const EmailTemplateWidget(this.template, {super.key});

  @override
  Widget build(BuildContext context) {
    return ScannerResultPage(
      title: 'Email',
      actions: [],
      template: template,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (template.tos != null) Text('To: ${template.tos!.join(', ')}'),
          if (template.ccs != null) Text('CC: ${template.ccs!.join(', ')}'),
          if (template.bccs != null) Text('BCC: ${template.bccs!.join(', ')}'),
          if (template.subject != null) Text('Subject: ${template.subject}'),
          if (template.body != null) Text('Body: ${template.body}'),
        ],
      ),
    );
  }
}
