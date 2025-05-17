import 'package:flutter/material.dart';

import 'package:aqr/qr/qr_templates/email_template.dart';

class EmailTemplateWidget extends StatelessWidget {
  final EmailTemplate email;

  const EmailTemplateWidget({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (email.tos != null) Text('To: ${email.tos!.join(', ')}'),
        if (email.ccs != null) Text('CC: ${email.ccs!.join(', ')}'),
        if (email.bccs != null) Text('BCC: ${email.bccs!.join(', ')}'),
        if (email.subject != null) Text('Subject: ${email.subject}'),
        if (email.body != null) Text('Body: ${email.body}'),
      ],
    );
  }
}
