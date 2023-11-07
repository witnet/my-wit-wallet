import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:flutter/material.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/util/storage/database/transaction_adapter.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';

typedef void GeneralTransactionCallback(GeneralTransaction value);

class SpeedUpBtn extends StatefulWidget {
  final GeneralTransactionCallback speedUpTx;
  final GeneralTransaction transaction;

  SpeedUpBtn({Key? key, required this.speedUpTx, required this.transaction})
      : super(key: key);

  @override
  SpeedUpBtnState createState() => SpeedUpBtnState();
}

class SpeedUpBtnState extends State<SpeedUpBtn> {
  final ScrollController _scroller = ScrollController();
  Wallet currentWallet =
      Locator.instance.get<ApiDatabase>().walletStorage.currentWallet;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PaddedButton(
      padding: EdgeInsets.only(top: 8),
      text: localization.speedUp,
      onPressed: () => {
        widget.speedUpTx(widget.transaction),
      },
      type: ButtonType.small,
    );
  }
}
