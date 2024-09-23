import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:my_wit_wallet/theme/colors.dart';

class QrAddressGenerator extends StatefulWidget {
  QrAddressGenerator({
    required this.data,
  });
  final String data;
  @override
  State<QrAddressGenerator> createState() => QrAddressGeneratorState();
}

class QrAddressGeneratorState extends State<QrAddressGenerator> {
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final size = (deviceSize.width > 175) ? 154.0 : 154 * 0.7;

    return Container(
      child: Column(
        children: <Widget>[
          Container(
            color: theme.colorScheme.surface,
            child: Padding(
              padding: EdgeInsets.all(5),
              child: CustomPaint(
                size: Size.square(size),
                painter: QrPainter(
                  data: widget.data,
                  version: QrVersions.auto,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: WitnetPallet.brightCyan,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: WitnetPallet.brightCyan,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
