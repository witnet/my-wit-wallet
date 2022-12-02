import 'package:flutter/material.dart';
import 'package:witnet/explorer.dart';
import 'package:witnet_wallet/util/extensions/string_extensions.dart';
import 'package:witnet_wallet/util/extensions/timestamp_extensions.dart';
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
        InfoElement(label: 'Fee', text: transaction.fee.toString()),
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
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(transaction.inputs[index].address,
                        style: theme.textTheme.bodyText1),
                    Text(transaction.inputs[index].value.toString(),
                        style: theme.textTheme.bodyText1),
                  ]);
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
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(transaction.outputs[index].pkh.address.toString(),
                        style: theme.textTheme.bodyText1),
                    Text(transaction.outputs[index].value.toString(),
                        style: theme.textTheme.bodyText1),
                    Text(transaction.outputs[index].timeLock.toString(),
                        style: theme.textTheme.bodyText1),
                  ]);
            },
          ),
        ]),
      ],
    );
  }
}
