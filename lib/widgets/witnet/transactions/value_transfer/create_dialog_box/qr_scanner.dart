import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

typedef void StringCallback(String value);

class QrScanner extends StatelessWidget {
  final StringCallback onChanged;
  final String currentRoute;
  const QrScanner({
    Key? key,
    required this.currentRoute,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppLocalizations _localization = AppLocalizations.of(context)!;
    return Scaffold(
        backgroundColor: Colors.black,
        body: Builder(builder: (context) {
          return Stack(children: [
            MobileScanner(
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  onChanged(barcode.rawValue ?? '');
                }
              },
            ),
            SafeArea(
                child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                        alignment: Alignment.topCenter,
                        height: 50,
                        color: Colors.transparent,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(FontAwesomeIcons.arrowLeft, size: 18),
                              color: Colors.white,
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                    context, currentRoute);
                              },
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 16),
                              child: Text(_localization.scanAqrCode,
                                  style: TextStyle(color: Colors.white)),
                            )
                          ],
                        ))))
          ]);
        }));
  }
}
