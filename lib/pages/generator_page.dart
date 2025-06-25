import 'package:flutter/material.dart';

import 'package:aqr_lib/core.dart';
import 'package:aqr_lib/encoder.dart';

import 'package:aqr_app/pages/constructor_page.dart';
import 'package:aqr_app/pages/generator_result_page.dart';

import '../template_forms/calendar_event_form.dart';
import '../template_forms/contact_info_template_form.dart';
import '../template_forms/email_template_form.dart';
import '../template_forms/geolocation_template_form.dart';
import '../template_forms/phone_number_template_form.dart';
import '../template_forms/sms_template_form.dart';
import '../template_forms/url_template_form.dart';
import '../template_forms/wifi_template_form.dart';
import '../widgets/template_form_wrapper.dart';
import '../widgets/text_to_qr_form.dart';

class GeneratorPage extends StatefulWidget {
  const GeneratorPage({super.key});

  @override
  State<GeneratorPage> createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage> {
  static const clOptions = [
    (cl: 0, label: '0 (regular QR)'),
    (cl: 1, label: '1'),
    (cl: 2, label: '2'),
    (cl: 3, label: '3 (less stable)'),
  ];
  static const eclOptions = [
    (ecl: ErrorCorrection.L, label: 'L', recovery: 7),
    (ecl: ErrorCorrection.M, label: 'M', recovery: 15),
    (ecl: ErrorCorrection.Q, label: 'Q', recovery: 25),
    (ecl: ErrorCorrection.H, label: 'H', recovery: 30),
  ];

  var clOption = clOptions[0];
  var eclOption = eclOptions[1];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        ExpansionTile(
          shape: const Border(),
          leading: const Icon(Icons.settings),
          title: const Text('Settings'),
          subtitle: const Text('Parameters of generated codes'),
          childrenPadding: const EdgeInsets.only(left: 16.0),
          children: [
            DropdownButtonFormField(
              decoration: const InputDecoration(
                labelText: 'Compression level',
              ),
              padding: const EdgeInsets.all(16.0),
              value: clOption,
              items: clOptions
                  .map((o) => DropdownMenuItem(value: o, child: Text(o.label)))
                  .toList(),
              onChanged: (o) => setState(() => clOption = o ?? clOptions[0]),
            ),
            DropdownButtonFormField(
              decoration: const InputDecoration(
                labelText: 'Error correction level',
              ),
              padding: const EdgeInsets.all(16.0),
              value: eclOption,
              items: eclOptions
                  .map((o) => DropdownMenuItem(
                      value: o,
                      child: Text(
                          '${o.label} (up to ${o.recovery}% data recovery)')))
                  .toList(),
              onChanged: (o) => setState(() => eclOption = o ?? eclOptions[1]),
            ),
          ],
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.text_fields),
          title: const Text('Text'),
          subtitle: const Text('Just write anything'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TemplateFormWrapper(
                  builder: (context, key) => TextToAqrForm(
                    key: key,
                    onSubmit: make,
                  ),
                  name: 'Text',
                ),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.extension),
          title: const Text('Constructor'),
          subtitle: const Text('Make QR from data segments'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ConstructorPage(onSubmit: makeFromSegments),
              ),
            );
          },
        ),
        ExpansionTile(
          shape: const Border(),
          leading: const Icon(Icons.dashboard),
          title: const Text('Templates'),
          subtitle: const Text('Email, SMS, URL, Wi-Fi, etc.'),
          childrenPadding: const EdgeInsets.only(left: 16.0),
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('Calendar event'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TemplateFormWrapper(
                      builder: (context, key) => CalendarEventForm(
                        key: key,
                        onSubmit: onTemplateFormSubmit,
                      ),
                      name: 'Calendar event',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.contact_page),
              title: const Text('Contact info'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TemplateFormWrapper(
                      builder: (context, key) => ContactInfoTemplateForm(
                        key: key,
                        onSubmit: onTemplateFormSubmit,
                      ),
                      name: 'Contact info',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.alternate_email),
              title: const Text('Email'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TemplateFormWrapper(
                      builder: (context, key) => EmailTemplateForm(
                        key: key,
                        onSubmit: onTemplateFormSubmit,
                      ),
                      name: 'Email',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Geolocation'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TemplateFormWrapper(
                      builder: (context, key) => GeolocationTemplateForm(
                        key: key,
                        onSubmit: onTemplateFormSubmit,
                      ),
                      name: 'Geolocation',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Phone number'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TemplateFormWrapper(
                      builder: (context, key) => PhoneNumberTemplateForm(
                        key: key,
                        onSubmit: onTemplateFormSubmit,
                      ),
                      name: 'Phone number',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.sms),
              title: const Text('SMS'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TemplateFormWrapper(
                      builder: (context, key) => SmsTemplateForm(
                        key: key,
                        onSubmit: onTemplateFormSubmit,
                      ),
                      name: 'SMS',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('URL'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TemplateFormWrapper(
                      builder: (context, key) => UrlTemplateForm(
                        key: key,
                        onSubmit: onTemplateFormSubmit,
                      ),
                      name: 'URL',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.wifi),
              title: const Text('Wi-Fi'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TemplateFormWrapper(
                      builder: (context, key) => WifiTemplateForm(
                        key: key,
                        onSubmit: onTemplateFormSubmit,
                      ),
                      name: 'Wi-Fi',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  void onTemplateFormSubmit(BuildContext context, Template template) {
    make(context, template.displayResult);
  }

  void makeFromSegments(BuildContext context, List<Segment> segments) {
    final symbol = Encoder().encodeSegments(
      data: segments,
      meta: AqrMeta(
        compression: Compression(level: clOption.cl),
        errorCorrection: eclOption.ecl,
      ),
    );

    showResult(context, symbol, segments.map((e) => e.content).join());
  }

  void make(BuildContext context, String text) {
    final symbol = Encoder().encode(
      data: text,
      meta: AqrMeta(
        compression: Compression(level: clOption.cl),
        errorCorrection: eclOption.ecl,
      ),
    );

    showResult(context, symbol, text);
  }

  void showResult(BuildContext context, AqrCode symbol, String raw) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            GeneratorResultPage(title: 'AQR', aqr: symbol, raw: raw),
      ),
    );

    // final image = symbol.draw();
    // final bytes =
    //     imglib.encodePng(imglib.copyResize(image, width: 500, height: 500));

    // showModalBottomSheet(
    //   context: context,
    //   shape: const Border(),
    //   builder: (context) => SingleChildScrollView(
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.start,
    //       children: [
    //         Padding(
    //           padding: const EdgeInsets.all(8.0),
    //           child: Row(
    //             mainAxisAlignment: MainAxisAlignment.end,
    //             children: [
    //               IconButton(
    //                   onPressed: () async {
    //                     await FilePicker.platform.saveFile(
    //                         fileName: 'aqr.png',
    //                         allowedExtensions: ['png'],
    //                         bytes: bytes);
    //                   },
    //                   icon: const Icon(Icons.save_alt))
    //             ],
    //           ),
    //         ),
    //         Image.memory(bytes),
    //       ],
    //     ),
    //   ),
    // );
  }
}
