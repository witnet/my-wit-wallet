import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wit_wallet/bloc/explorer/explorer_bloc.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/theme/colors.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/util/storage/database/account.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/util/extensions/string_extensions.dart';
import 'package:my_wit_wallet/widgets/snack_bars.dart';
import 'package:my_wit_wallet/util/extensions/num_extensions.dart';

class AddreessItem extends StatefulWidget {
  final bool isLastItem;
  final Account account;
  final String? currentAddress;
  const AddreessItem(
      {Key? key,
      required this.isLastItem,
      required this.account,
      required this.currentAddress})
      : super(key: key);

  @override
  State<AddreessItem> createState() => AddreessItemState();
}

class AddreessItemState extends State<AddreessItem>
    with WidgetsBindingObserver {
  bool isAddressCopied = false;
  bool isAddressSelected = false;

  @override
  void initState() {
    super.initState();
    isAddressSelected = widget.account.address == widget.currentAddress;
  }

  _syncSpinnerOrBalanceDisplay(Account account, ThemeData theme) {
    ExtendedTheme extendedTheme = theme.extension<ExtendedTheme>()!;
    final isAddressSelected = account.address == widget.currentAddress;
    final textStyle = isAddressSelected
        ? extendedTheme.monoMediumText
        : extendedTheme.monoRegularText;

    return BlocBuilder<ExplorerBloc, ExplorerState>(
        builder: (BuildContext context, ExplorerState state) {
      if (state.status == ExplorerStatus.singleSync &&
          state.data['address'] == account.address) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                  color: theme.textTheme.labelMedium?.color,
                  strokeWidth: 2,
                  value: null,
                  semanticsLabel: 'Circular progress indicator',
                ))
          ],
        );
      } else {
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Received payments totalling',
              textAlign: TextAlign.start,
              style: textStyle!.copyWith(
                  fontFamily: 'Almarai',
                  fontWeight: FontWeight.w300,
                  fontSize: 12)),
          SizedBox(height: 4),
          Text(
              '${account.balance.availableNanoWit.standardizeWitUnits().formatWithCommaSeparator()} ${WIT_UNIT[WitUnit.Wit]}',
              textAlign: TextAlign.start,
              style: textStyle.copyWith(
                  fontFamily: 'Almarai',
                  fontWeight: FontWeight.w300,
                  fontSize: 12)),
        ]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    ExtendedTheme extendedTheme = theme.extension<ExtendedTheme>()!;
    final textStyle = isAddressSelected
        ? extendedTheme.monoMediumText
        : extendedTheme.monoRegularText;
    return Container(
      decoration: BoxDecoration(
        color: WitnetPallet.transparent,
        border: !widget.isLastItem
            ? Border(
                bottom: BorderSide(
                color: extendedTheme.txBorderColor!,
                width: 1,
              ))
            : null,
      ),
      child: Padding(
        padding: EdgeInsets.only(top: 16, bottom: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(
                    widget.account.address.cropMiddle(33),
                    overflow: TextOverflow.ellipsis,
                    style: textStyle,
                  ),
                  SizedBox(height: 8),
                  _syncSpinnerOrBalanceDisplay(widget.account, theme),
                ])),
            PaddedButton(
              padding: EdgeInsets.zero,
              label: localization.copyAddressToClipboard,
              text: localization.copyAddressToClipboard,
              type: ButtonType.iconButton,
              iconSize: 12,
              onPressed: () async {
                if (!isAddressCopied) {
                  await Clipboard.setData(
                      ClipboardData(text: widget.account.address));
                  if (await Clipboard.hasStrings()) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                        buildCopiedSnackbar(theme, localization.addressCopied));
                    setState(() {
                      isAddressCopied = true;
                    });
                    if (this.mounted) {
                      Timer(Duration(milliseconds: 500), () {
                        setState(() {
                          isAddressCopied = false;
                        });
                      });
                    }
                  }
                }
              },
              icon: Icon(
                isAddressCopied
                    ? FontAwesomeIcons.check
                    : FontAwesomeIcons.copy,
                size: 12,
              ),
            )
          ],
        ),
      ),
    );
  }
}
