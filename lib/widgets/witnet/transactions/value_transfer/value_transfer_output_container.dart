import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:witnet/schema.dart';
import 'package:witnet/utils.dart';

import '../../../auto_size_text.dart';

class ValueTransferOutputContainer extends StatelessWidget {
  ValueTransferOutputContainer({required this.vto});
  final ValueTransferOutput vto;
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    double cardWidth;
    if (deviceSize.width > 400) {
      cardWidth = (400 * 0.7);
    } else
      cardWidth = deviceSize.width * 0.7;
    return Container(
      width: cardWidth,
      padding: EdgeInsets.all(3),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  flex: 1,
                  child: Icon(
                    FontAwesomeIcons.addressCard,
                    color: theme.accentColor,
                  )),
              Expanded(
                  flex: 5,
                  child: AutoSizeText(
                    vto.pkh.address,
                    maxLines: 1,
                    minFontSize: 9,
                  ))
            ],
          ),
          Row(
            children: [
              Expanded(
                  flex: 8,
                  child: AutoSizeText(
                    nanoWitToWit(vto.value).toStringAsFixed(9),
                    maxLines: 1,
                    minFontSize: 9,
                    textAlign: TextAlign.right,
                  )),
              SizedBox(
                width: 3,
              ),
              Expanded(
                flex: 1,
                child: Image.asset(
                  'assets/img/favicon.ico',
                ),
              ),
              SizedBox(
                width: 3,
              ),
              Expanded(
                  flex: 1,
                  child: AutoSizeText(
                    'WIT',
                    maxLines: 1,
                    minFontSize: 9,
                    textAlign: TextAlign.right,
                  )),
            ],
          ),
        ],
      ),
    );
  }
}
