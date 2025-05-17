import 'package:flutter/material.dart';

import 'package:image/image.dart' as imglib;
import 'package:zxing_lib/qrcode.dart';

import 'package:aqr/qr/template.dart';
import 'package:aqr/widgets/qr_template_form_wrapper.dart';
import 'package:aqr/widgets/qr_template_forms.dart/calendar_event_form.dart';
import 'package:aqr/widgets/qr_template_forms.dart/contact_info_template_form.dart';
import 'package:aqr/widgets/qr_template_forms.dart/email_template_form.dart';
import 'package:aqr/widgets/qr_template_forms.dart/geolocation_template_form.dart';
import 'package:aqr/widgets/qr_template_forms.dart/phone_number_template_form.dart';
import 'package:aqr/widgets/qr_template_forms.dart/sms_template_form.dart';
import 'package:aqr/widgets/qr_template_forms.dart/url_template_form.dart';
import 'package:aqr/widgets/qr_template_forms.dart/wifi_template_form.dart';
import 'package:aqr/widgets/text_to_qr_form.dart';

class GeneratorPage extends StatefulWidget {
  const GeneratorPage({super.key});

  @override
  State<GeneratorPage> createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage> {
  static const eclOptions = [
    (ecl: ErrorCorrectionLevel.L, label: 'L', recovery: 7),
    (ecl: ErrorCorrectionLevel.M, label: 'M', recovery: 15),
    (ecl: ErrorCorrectionLevel.Q, label: 'Q', recovery: 25),
    (ecl: ErrorCorrectionLevel.H, label: 'H', recovery: 30),
  ];
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
                builder: (context) => QrTemplateFormWrapper(
                  builder: (context) => TextToQrForm(onSubmit: makeQr),
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
          onTap: () {},
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
                    builder: (context) => QrTemplateFormWrapper(
                      builder: (context) => CalendarEventForm(
                        onSubmit: onSubmit,
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
                    builder: (context) => QrTemplateFormWrapper(
                      builder: (context) =>
                          ContactInfoTemplateForm(onSubmit: onSubmit),
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
                    builder: (context) => QrTemplateFormWrapper(
                      builder: (context) => EmailTemplateForm(
                        onSubmit: onSubmit,
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
                    builder: (context) => QrTemplateFormWrapper(
                      builder: (context) =>
                          GeolocationTemplateForm(onSubmit: onSubmit),
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
                    builder: (context) => QrTemplateFormWrapper(
                      builder: (context) =>
                          PhoneNumberTemplateForm(onSubmit: onSubmit),
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
                    builder: (context) => QrTemplateFormWrapper(
                      builder: (context) => SmsTemplateForm(onSubmit: onSubmit),
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
                    builder: (context) => QrTemplateFormWrapper(
                      builder: (context) => UrlTemplateForm(onSubmit: onSubmit),
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
                    builder: (context) => QrTemplateFormWrapper(
                      builder: (context) =>
                          WifiTemplateForm(onSubmit: onSubmit),
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

  void onSubmit(BuildContext context, Template template) {
    makeQr(context, template.displayResult);
  }

  void makeQr(BuildContext context, String text) {
    final qrCode = Encoder.encode(text, eclOption.ecl);
    final matrix = qrCode.matrix!;
    final image = imglib.Image(
      width: matrix.width,
      height: matrix.height,
    );
    final black = imglib.ColorRgb8(0, 0, 0);
    final white = imglib.ColorRgb8(255, 255, 255);

    for (int x = 0; x < matrix.width; x++) {
      for (int y = 0; y < matrix.height; y++) {
        image.setPixel(x, y, matrix.get(x, y) == 1 ? black : white);
      }
    }

    showModalBottomSheet(
      context: context,
      shape: const Border(),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Image.memory(
          imglib.encodePng(imglib.copyResize(image, width: 500, height: 500)),
          fit: BoxFit.contain,
          width: 500,
          height: 500,
        ),
      ),
    );
  }
}
