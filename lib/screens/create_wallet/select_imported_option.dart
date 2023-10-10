import 'package:flutter/material.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:my_wit_wallet/screens/login/bloc/login_bloc.dart';
import 'package:my_wit_wallet/screens/create_wallet/bloc/api_create_wallet.dart';
import 'package:my_wit_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:my_wit_wallet/screens/create_wallet/nav_action.dart';
import 'package:my_wit_wallet/theme/wallet_theme.dart';

typedef void VoidCallback(NavAction? value);
typedef void BoolCallback(bool value);

class SelectImportedOption extends StatefulWidget {
  final Function nextAction;
  final Function secondaryAction;
  final Function prevAction;
  final Function clearActions;

  SelectImportedOption({
    Key? key,
    required VoidCallback this.nextAction,
    required VoidCallback this.secondaryAction,
    required VoidCallback this.prevAction,
    required BoolCallback this.clearActions,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => ImportedOptionState();
}

class ImportedOptionState extends State<SelectImportedOption> {
  AppLocalizations get _localization => AppLocalizations.of(context)!;

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 8, bottom: 8),
          child: _buildInitialButtons(context, theme),
        ),
      ],
    );
  }

  void prevAction() {
    CreateWalletType type =
        BlocProvider.of<CreateWalletBloc>(context).state.createWalletType;
    LoginStatus status = BlocProvider.of<LoginBloc>(context).state.status;
    if (status != LoginStatus.LoginSuccess) {
      Navigator.pushNamed(context, '/');
    } else {
      BlocProvider.of<CreateWalletBloc>(context).add(PreviousCardEvent(type));
    }
  }

  void nextSeedAction() {
    widget.clearActions(true);
    Locator.instance<ApiCreateWallet>()
        .setCreateWalletType(CreateWalletType.mnemonic);
    BlocProvider.of<CreateWalletBloc>(context)
        .add(ResetEvent(CreateWalletType.mnemonic));
    BlocProvider.of<CreateWalletBloc>(context).add(NextCardEvent(
        Locator.instance<ApiCreateWallet>().createWalletType,
        data: {}));
  }

  void nextXprvAction() {
    widget.clearActions(true);
    Locator.instance<ApiCreateWallet>()
        .setCreateWalletType(CreateWalletType.encryptedXprv);
    BlocProvider.of<CreateWalletBloc>(context)
        .add(ResetEvent(CreateWalletType.encryptedXprv));
    BlocProvider.of<CreateWalletBloc>(context).add(NextCardEvent(
        Locator.instance<ApiCreateWallet>().createWalletType,
        data: {}));
  }

  NavAction prev() {
    return NavAction(
      label: _localization.backLabel,
      action: prevAction,
    );
  }

  NavAction nextSeed() {
    return NavAction(
      label: _localization.importMnemonicLabel,
      action: nextSeedAction,
    );
  }

  NavAction nextXprv() {
    return NavAction(
      label: _localization.importXprvLabel,
      action: nextXprvAction,
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.prevAction(prev));
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.nextAction(nextSeed));
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.secondaryAction(nextXprv));
    super.initState();
  }

  Widget _buildInitialButtons(BuildContext context, ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Center(child: svgThemeImage(theme, name: 'import-wallet', height: 152)),
        SizedBox(height: 16),
        Text(
          _localization.selectImportOptionHeader,
          style: theme.textTheme.titleLarge,
        ),
        SizedBox(height: 16),
        Text(
          _localization.createImportWallet01,
          style: theme.textTheme.bodyLarge,
        ),
        SizedBox(height: 16),
        Text(_localization.createImportWallet02,
            style: theme.textTheme.bodyLarge),
      ],
    );
  }
}
