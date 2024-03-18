import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wit_wallet/util/get_localization.dart';

import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';

import 'package:my_wit_wallet/screens/dashboard/bloc/dashboard_bloc.dart';

class EditWalletDetails extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => EditWalletDetailsState();
}

class EditWalletDetailsState extends State<EditWalletDetails> {
  late TextEditingController _nameController;
  final _focusNode = FocusNode();
  String _walletName = '';
  String? errorText;
  bool editName = false;

  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _nameController.value = TextEditingValue(
        text: Locator.instance
            .get<ApiDatabase>()
            .walletStorage
            .currentWallet
            .name);
    _walletName = _nameController.value.text;
  }

  void _updateWalletName(String data) {
    Wallet _wallet =
        Locator.instance.get<ApiDatabase>().walletStorage.currentWallet;
    setState(() {
      FocusManager.instance.primaryFocus?.unfocus();
      _walletName = data;
      Locator.instance.get<ApiDatabase>().deleteWallet(_wallet);
      _wallet.name = _walletName;
      Locator.instance.get<ApiDatabase>().addWallet(_wallet);
      Locator.instance
          .get<ApiDatabase>()
          .walletStorage
          .setCurrentWallet(_wallet.id);
      editName = false;
    });
    BlocProvider.of<DashboardBloc>(context).add(DashboardUpdateWalletEvent(
        currentWallet: _wallet,
        currentAddress: Locator.instance
            .get<ApiDatabase>()
            .walletStorage
            .currentAccount
            .address));
  }

  String get currentWalletName =>
      Locator.instance.get<ApiDatabase>().walletStorage.currentWallet.name;

  Widget buildNameInputOrText(theme) {
    IconButton editNameBtn = IconButton(
        onPressed: () => {setState(() => editName = !editName)},
        icon: Icon(FontAwesomeIcons.pen));
    IconButton confirmBtn = IconButton(
        onPressed: () => {
              setState(() {
                editName = !editName;
                this._updateWalletName(_walletName);
              })
            },
        icon: Icon(FontAwesomeIcons.check));
    if (!editName) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 16),
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  currentWalletName,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyText1,
                ),
                editNameBtn,
              ],
            ),
          )
        ],
      );
    } else {
      return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: TextField(
                autofocus: true,
                style: theme.textTheme.bodyText1,
                decoration: InputDecoration(
                  hintText: localization.walletNameHint,
                  errorText: errorText,
                ),
                controller: _nameController,
                focusNode: _focusNode,
                onSubmitted: _updateWalletName,
                onChanged: (String value) {
                  setState(() {
                    _walletName = value;
                  });
                },
              ),
            ),
            SizedBox(width: 8),
            confirmBtn,
          ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildNameInputOrText(theme),
        SizedBox(height: 16),
      ],
    );
  }
}
