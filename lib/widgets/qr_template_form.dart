import 'package:flutter/material.dart';

import 'package:aqr/qr/template.dart';
import 'package:aqr/qr/template_parser.dart';

typedef OnSubmitCallback<T> = void Function(BuildContext context, T template);

abstract class QrTemplateForm<T extends Template> extends StatefulWidget {
  final TemplateParser<T> parser;
  final OnSubmitCallback<T> onSubmit;

  const QrTemplateForm(
      {super.key, required this.parser, required this.onSubmit});
}
