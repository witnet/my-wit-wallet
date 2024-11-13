import 'package:flutter/material.dart';
import 'package:my_wit_wallet/widgets/buttons/custom_btn.dart';
import 'package:my_wit_wallet/widgets/layouts/layout.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/screens/create_wallet/bloc/api_create_wallet.dart';
import 'package:my_wit_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:my_wit_wallet/screens/create_wallet/create_wallet_screen.dart';
import 'package:my_wit_wallet/shared/locator.dart';

class FtuActions extends StatefulWidget {
  final List<Widget> mainComponents;
  FtuActions({Key? key, required this.mainComponents}) : super(key: key);

  @override
  FtuActionsState createState() => FtuActionsState();
}

class FtuActionsState extends State<FtuActions> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildInitialButtons(BuildContext context, ThemeData theme) {
    return Column(
      children: <Widget>[
        CustomButton(
            padding: EdgeInsets.only(top: 8, bottom: 0),
            text: localization.createNewWalletLabel,
            type: CustomBtnType.primary,
            onPressed: () => _createNewWallet(context)),
        CustomButton(
            padding: EdgeInsets.only(top: 8, bottom: 0),
            text: localization.importWalletLabel,
            type: CustomBtnType.secondary,
            onPressed: () => _importWallet(context)),
      ],
    );
  }

  // Call the methods to create or import a wallet according to the argument given
  void _createOrImportWallet(BuildContext context, CreateWalletType type) {
    Locator.instance<ApiCreateWallet>().setCreateWalletType(type);
    Navigator.pushReplacementNamed(context, CreateWalletScreen.route);
    BlocProvider.of<CreateWalletBloc>(context).add(ResetEvent(type));
  }

  void _createNewWallet(BuildContext context) {
    _createOrImportWallet(context, CreateWalletType.newWallet);
  }

  void _importWallet(BuildContext context) {
    _createOrImportWallet(context, CreateWalletType.imported);
  }

  @override
  Layout build(BuildContext context) {
    final theme = Theme.of(context);
    return Layout(
      topNavigation: [],
      widgetList: widget.mainComponents,
      actions: [_buildInitialButtons(context, theme)],
    );
  }
}
