import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:my_wit_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:my_wit_wallet/screens/login/bloc/login_bloc.dart';
import 'package:my_wit_wallet/widgets/labeled_checkbox.dart';
import 'package:my_wit_wallet/screens/create_wallet/nav_action.dart';

typedef void VoidCallback(NavAction? value);

class DisclaimerCard extends StatefulWidget {
  final Function nextAction;
  final Function prevAction;

  DisclaimerCard({
    Key? key,
    required VoidCallback this.nextAction,
    required VoidCallback this.prevAction,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => DisclaimerCardState();
}

class DisclaimerCardState extends State<DisclaimerCard>
    with TickerProviderStateMixin {
  List<AnimationController> _providerControllerList = <AnimationController>[];
  bool isNextAllow = false;
  bool isCheckBoxFocus = false;
  FocusNode _checkBoxFocusNode = FocusNode();

  AppLocalizations get _localization => AppLocalizations.of(context)!;

  @override
  void initState() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.prevAction(prev));
    _checkBoxFocusNode.addListener(_handleFocus);
    super.initState();
  }

  @override
  void dispose() {
    _checkBoxFocusNode.removeListener(_handleFocus);
    super.dispose();
    _providerControllerList.forEach((controller) {
      controller.dispose();
    });
  }

  _handleFocus() {
    setState(() {
      this.isCheckBoxFocus = _checkBoxFocusNode.hasFocus;
    });
  }

  void prevAction() {
    CreateWalletType type =
        BlocProvider.of<CreateWalletBloc>(context).state.createWalletType;
    LoginStatus status = BlocProvider.of<LoginBloc>(context).state.status;
    if (type == CreateWalletType.newWallet &&
        status != LoginStatus.LoginSuccess) {
      Navigator.pushNamed(context, '/');
    } else {
      BlocProvider.of<CreateWalletBloc>(context).add(PreviousCardEvent(type));
    }
  }

  void nextAction() {
    CreateWalletType type =
        BlocProvider.of<CreateWalletBloc>(context).state.createWalletType;
    BlocProvider.of<CreateWalletBloc>(context)
        .add(NextCardEvent(type, data: {}));
  }

  NavAction prev() {
    return NavAction(
      label: _localization.backLabel,
      action: prevAction,
    );
  }

  NavAction next() {
    return NavAction(
      label: _localization.continueLabel,
      action: nextAction,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(
          _localization.walletSecurityHeader,
          style: theme.textTheme.titleLarge!,
        ),
        SizedBox(
          height: 16,
        ),
        Text(
          _localization.walletSecurity01,
          style: theme.textTheme.bodyLarge,
        ),
        SizedBox(
          height: 10,
        ),
        Text(_localization.walletSecurity02, style: theme.textTheme.bodyLarge),
        SizedBox(
          height: 10,
        ),
        Text(_localization.walletSecurity03, style: theme.textTheme.bodyLarge),
        SizedBox(
          height: 10,
        ),
        Text(_localization.walletSecurity04, style: theme.textTheme.bodyLarge),
        SizedBox(
          height: 10,
        ),
        Text(_localization.walletSecurity05, style: theme.textTheme.bodyLarge),
        SizedBox(
          height: 10,
        ),
        Text(_localization.walletSecurity06, style: theme.textTheme.bodyLarge),
        SizedBox(
          height: 10,
        ),
        LabeledCheckbox(
            focusNode: _checkBoxFocusNode,
            isFocus: isCheckBoxFocus,
            checked: isNextAllow,
            label: _localization.walletSecurityConfirmLabel,
            onChanged: (value) => {
                  setState(() {
                    isNextAllow = !isNextAllow;
                  }),
                  if (isNextAllow)
                    {widget.nextAction(next)}
                  else
                    {widget.nextAction(null)}
                })
      ],
    );
  }
}
