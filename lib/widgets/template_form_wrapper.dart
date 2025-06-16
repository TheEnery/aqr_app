import 'package:flutter/material.dart';

import 'package:aqr_app/widgets/template_form.dart';

class TemplateFormWrapper extends StatelessWidget {
  final String name;
  final Widget Function(BuildContext context, GlobalKey key) builder;
  final GlobalKey<TemplateFormState> templateFormKey = GlobalKey();

  TemplateFormWrapper({
    super.key,
    required this.builder,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        actions: [
          IconButton(
            onPressed: () {
              templateFormKey.currentState?.submit();
            },
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: builder(context, templateFormKey),
      ),
    );
  }
}
