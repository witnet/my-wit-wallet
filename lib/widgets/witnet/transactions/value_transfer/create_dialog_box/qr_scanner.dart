import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/util/storage/scanned_content.dart';
import 'package:my_wit_wallet/widgets/suffix_icon_button.dart';

typedef void StringCallback(String value);

class QrScanner extends StatelessWidget {
  static final route = '/scan';
  final StringCallback onChanged;
  final String currentRoute;
  final ScannedType type;
  const QrScanner(
      {Key? key,
      required this.currentRoute,
      required this.onChanged,
      required this.type})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    ScannedContent scannedContent = ScannedContent();
    return Scaffold(
        backgroundColor: Colors.black,
        body: Builder(builder: (context) {
          return Stack(children: [
            MobileScanner(
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  onChanged(barcode.rawValue ?? '');
                  scannedContent.setScannedContent(
                      value: barcode.rawValue ?? '', type: type);
                  Navigator.popUntil(
                      context, ModalRoute.withName(this.currentRoute));
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
                            SuffixIcon(
                                onPressed: () {
                                  Navigator.popUntil(context,
                                      ModalRoute.withName(this.currentRoute));
                                },
                                color: Colors.white,
                                icon: FontAwesomeIcons.arrowLeft,
                                isFocus: false,
                                focusNode: FocusNode()),
                            Padding(
                              padding: EdgeInsets.only(right: 16),
                              child: Text(localization.scanAqrCode,
                                  style: theme.textTheme.bodyMedium
                                      ?.copyWith(color: Colors.white)),
                            )
                          ],
                        ))))
          ]);
        }));
  }
}
