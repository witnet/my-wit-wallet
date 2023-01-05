import 'package:flutter/material.dart';
import 'package:witnet/explorer.dart';
import 'package:witnet/schema.dart';
import 'package:witnet_wallet/theme/colors.dart';
import 'package:witnet_wallet/theme/extended_theme.dart';
import 'package:witnet_wallet/util/extensions/string_extensions.dart';
import 'package:witnet_wallet/util/extensions/int_extensions.dart';
import 'package:witnet_wallet/util/extensions/num_extensions.dart';
import 'package:witnet_wallet/widgets/PaddedButton.dart';
import 'package:witnet_wallet/widgets/info_element.dart';

typedef void VoidCallback();

class TransactionDetails extends StatelessWidget {
  final ValueTransferInfo transaction;
  final VoidCallback goToList;

  const TransactionDetails({
    required this.transaction,
    required this.goToList,
  });

  Widget _buildOutput(
      ThemeData theme, ValueTransferOutput output, bool isLastOutput) {
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    Widget timelock = SizedBox(height: 0);
    if (output.timeLock != 0) {
      timelock = Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
            Text(output.timeLock.toInt().formatDate(), style: theme.textTheme.caption)
          ]));
    }
    return Container(
        padding: EdgeInsets.only(top: 16, bottom: 16),
        decoration: BoxDecoration(
          color: WitnetPallet.transparent,
          border: Border(
              bottom: BorderSide(
            color: !isLastOutput
                ? extendedTheme.txBorderColor!
                : WitnetPallet.transparent,
            width: 1,
          )),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(output.pkh.address.toString(),
                      style: theme.textTheme.bodyText1),
                  SizedBox(height: 8),
                  Text('${output.value.toInt().standardizeWitUnits()} Wit',
                      style: theme.textTheme.labelMedium),
                ],
              ),
            ),
            SizedBox(width: 8),
            timelock,
          ],
        ));
  }

  Widget _buildInput(ThemeData theme, InputUtxo input, bool isLastInput) {
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    return Container(
        padding: EdgeInsets.only(top: 8, bottom: 8),
        decoration: BoxDecoration(
          color: WitnetPallet.transparent,
          border: Border(
              bottom: BorderSide(
            color: !isLastInput
                ? extendedTheme.txBorderColor!
                : WitnetPallet.transparent,
            width: 1,
          )),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(input.address.toString(), style: theme.textTheme.bodyText1),
            SizedBox(height: 8),
            Text('${input.value.standardizeWitUnits()} Wit',
                style: theme.textTheme.labelMedium),
          ],
        ));
  }

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PaddedButton(
            padding: EdgeInsets.all(0),
            text: 'Back',
            onPressed: () => goToList(),
            type: 'text'),
        SizedBox(height: 16),
        Text(
          'Transaction details',
          style: theme.textTheme.headline3,
        ),
        SizedBox(height: 24),
        InfoElement(
            label: 'Status',
            text: transaction.status.capitalize(),
            color: theme.textTheme.labelMedium?.color),
        SizedBox(height: 16),
        InfoElement(
          label: 'Transaction ID',
          text: transaction.txnHash,
          url: 'https://witnet.network/search/${transaction.txnHash}',
        ),
        SizedBox(height: 16),
        InfoElement(label: 'Epoch', text: transaction.txnEpoch.toString()),
        SizedBox(height: 16),
        InfoElement(
            label: 'Type',
            text: transaction.type.split('_').join(' ').toTitleCase()),
        SizedBox(height: 16),
        InfoElement(
            label: 'Fee', text: '${transaction.fee.standardizeWitUnits()} Wit'),
        SizedBox(height: 16),
        InfoElement(label: 'Timestamp', text: transaction.txnTime.formatDate()),
        SizedBox(height: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            'Inputs',
            style: theme.textTheme.headline3,
          ),
          SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: transaction.inputs.length,
            itemBuilder: (context, index) {
              return _buildInput(theme, transaction.inputs[index],
                  index + 1 == transaction.inputs.length);
            },
          ),
        ]),
        SizedBox(height: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            'Outputs',
            style: theme.textTheme.headline3,
          ),
          SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: transaction.outputs.length,
            itemBuilder: (context, index) {
              return _buildOutput(theme, transaction.outputs[index],
                  index + 1 == transaction.outputs.length);
            },
          ),
        ]),
      ],
    );
  }
}
