import 'package:flutter/material.dart';

import 'package:aqr_lib/core.dart';

typedef OnSubmitCallback<T> = void Function(BuildContext context, T template);

abstract class TemplateForm<T extends Template> extends StatefulWidget {
  final TemplateParser<T> parser;
  final OnSubmitCallback<T> onSubmit;

  const TemplateForm({super.key, required this.parser, required this.onSubmit});
}

// TODO: remove this workaround
abstract class TemplateFormState<
    T /*extends TemplateForm*/ extends StatefulWidget> extends State<T> {
  void submit();
}
