import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:my_wit_wallet/screens/send_transaction/send_vtt_screen.dart';

typedef void StringCallback(String value);

class QrScanner extends StatelessWidget {
  final StringCallback onChanged;
  const QrScanner({
    Key? key,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Builder(builder: (context) {
          return Stack(children: [
            MobileScanner(
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                final Uint8List? image = capture.image;
                for (final barcode in barcodes) {
                  onChanged(barcode.rawValue ?? '');
                }
              },
            ),
            Align(
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
                                context, CreateVttScreen.route);
                          },
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 16),
                          child: Text('Scan a QR code',
                              style: TextStyle(color: Colors.white)),
                        )
                      ],
                    )))
          ]);
        }));
  }
}
