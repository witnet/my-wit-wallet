import 'package:flutter/material.dart';
import 'package:my_wit_wallet/screens/create_wallet/nav_action.dart';
import 'package:my_wit_wallet/theme/colors.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/util/extensions/num_extensions.dart';
import 'package:my_wit_wallet/util/extensions/int_extensions.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/widgets/info_element.dart';
import 'package:witnet/explorer.dart';

typedef void VoidCallback(NavAction? value);

class BlockStats extends StatefulWidget {
  final Wallet currentWallet;
  BlockStats({
    Key? key,
    required this.currentWallet,
  }) : super(key: key);

  BlockStatsState createState() => BlockStatsState();
}

class BlockStatsState extends State<BlockStats> with TickerProviderStateMixin {
  dynamic blocks;
  @override
  void initState() {
    super.initState();
  }

  Widget _buildBlockItem(BlockInfo block, ThemeData theme) {
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    return Container(
        margin: EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: WitnetPallet.transparent,
          border: Border(
              bottom: BorderSide(
            color: extendedTheme.txBorderColor!,
            width: 0.5,
          )),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(height: 16),
          InfoElement(label: 'Block ID', text: block.blockID),
          SizedBox(height: 16),
          InfoElement(label: 'Timestamp', text: block.timestamp.formatDate()),
          SizedBox(height: 16),
          InfoElement(label: 'Epoch', text: block.epoch.toString()),
          SizedBox(height: 16),
          InfoElement(
              label: 'Reward',
              text:
                  '${block.reward.standardizeWitUnits().formatWithCommaSeparator()} ${WIT_UNIT[WitUnit.Wit]}'),
          SizedBox(height: 16),
          InfoElement(
              label: 'Fees',
              text:
                  '${block.fees.standardizeWitUnits().formatWithCommaSeparator()} ${WIT_UNIT[WitUnit.Wit]}'),
          SizedBox(height: 16),
          InfoElement(
              label: 'Value transfer count',
              text: block.valueTransferCount.toString()),
          SizedBox(height: 16),
          InfoElement(
              label: 'DR count', text: block.dataRequestCount.toString()),
          SizedBox(height: 16),
          InfoElement(
              label: 'Commit count', text: block.commitCount.toString()),
          SizedBox(height: 16),
          InfoElement(
              label: 'Reveal count', text: block.revealCount.toString()),
          SizedBox(height: 16),
          InfoElement(label: 'Tally count', text: block.tallyCount.toString()),
          SizedBox(height: 16)
        ]));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    AddressBlocks? blocks = widget.currentWallet.masterAccountStats != null
        ? widget.currentWallet.masterAccountStats!.blocks
        : null;
    return Padding(
        padding: EdgeInsets.only(left: 12, right: 8),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              blocks != null
                  ? ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: blocks.blocks.length,
                      itemBuilder: (context, index) {
                        return _buildBlockItem(blocks.blocks[index], theme);
                      },
                    )
                  : Text('No blocks mined yet'),
            ]));
  }
}
