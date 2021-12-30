import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:witnet/schema.dart';
import 'package:witnet/utils.dart';
import 'package:witnet_wallet/bloc/transactions/value_transfer/create_vtt_bloc.dart';

import '../../../auto_size_text.dart';

class InputContainer extends StatelessWidget {
  InputContainer({
    required this.inputUtxo,
  });
  final InputUtxo inputUtxo;
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
                    FontAwesomeIcons.fileInvoice,
                    color: theme.accentColor,
                  )),
              SizedBox(
                width: 3,
              ),
              Expanded(
                  flex: 9,
                  child: AutoSizeText(
                    inputUtxo.address,
                    maxLines: 1,
                    minFontSize: 9,
                  )),
              SizedBox(
                width: 3,
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                  flex: 9,
                  child: AutoSizeText(
                    nanoWitToWit(inputUtxo.value).toStringAsFixed(9),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    minFontSize: 9,
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
