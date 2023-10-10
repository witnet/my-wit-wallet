import 'package:flutter/material.dart';
import 'package:my_wit_wallet/widgets/layouts/layout.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/screens/create_wallet/bloc/api_create_wallet.dart';
import 'package:my_wit_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:my_wit_wallet/screens/create_wallet/create_wallet_screen.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FtuActions extends StatefulWidget {
  final List<Widget> mainComponents;
  FtuActions({Key? key, required this.mainComponents}) : super(key: key);

  @override
  FtuActionsState createState() => FtuActionsState();
}

class FtuActionsState extends State<FtuActions> with TickerProviderStateMixin {
  AppLocalizations get _localization => AppLocalizations.of(context)!;

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
        PaddedButton(
            padding: EdgeInsets.only(top: 8, bottom: 0),
            text: _localization.createNewWalletLabel,
            type: ButtonType.primary,
            onPressed: () => _createNewWallet(context)),
        PaddedButton(
            padding: EdgeInsets.only(top: 8, bottom: 0),
            text: _localization.importWalletLabel,
            type: ButtonType.secondary,
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
      navigationActions: [],
      widgetList: widget.mainComponents,
      actions: [_buildInitialButtons(context, theme)],
    );
  }
}
