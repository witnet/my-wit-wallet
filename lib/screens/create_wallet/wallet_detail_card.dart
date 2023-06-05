import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/screens/create_wallet/bloc/api_create_wallet.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'bloc/create_wallet_bloc.dart';
import 'package:my_wit_wallet/screens/create_wallet/nav_action.dart';

typedef void VoidCallback(NavAction? value);
typedef void BoolCallback(bool value);

class WalletDetailCard extends StatefulWidget {
  final Function nextAction;
  final Function prevAction;
  final Function clearActions;
  WalletDetailCard({
    Key? key,
    required VoidCallback this.nextAction,
    required VoidCallback this.prevAction,
    required BoolCallback this.clearActions,
  }) : super(key: key);
  WalletDetailCardState createState() => WalletDetailCardState();
}

class WalletDetailCardState extends State<WalletDetailCard>
    with TickerProviderStateMixin {
  void prevAction() {
    WalletType type =
        BlocProvider.of<CreateWalletBloc>(context).state.walletType;
    BlocProvider.of<CreateWalletBloc>(context).add(PreviousCardEvent(type));
  }

  void nextAction() {
    if (validate(force: true)) {
      Locator.instance.get<ApiCreateWallet>().setWalletName(_walletName);
      Locator.instance
          .get<ApiCreateWallet>()
          .setWalletDescription(_walletDescription);
      WalletType type =
          BlocProvider.of<CreateWalletBloc>(context).state.walletType;
      BlocProvider.of<CreateWalletBloc>(context)
          .add(NextCardEvent(type, data: {}));
    }
  }

  NavAction prev() {
    return NavAction(
      label: 'Back',
      action: prevAction,
    );
  }

  NavAction next() {
    return NavAction(
      label: 'Continue',
      action: nextAction,
    );
  }

  late TextEditingController _nameController;
  late TextEditingController _descController;
  final _nameFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  String _walletName = '';
  String _walletDescription = '';
  String? errorText;
  String? defaultWalletName;
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descController = TextEditingController();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.prevAction(prev));
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.nextAction(next));
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.clearActions(false));
    defaultWalletName =
        "wallet-${Locator.instance.get<ApiDatabase>().walletStorage.wallets.length + 1}";
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _descController.dispose();
  }

  // ignore: todo
  // TODO[#24]: Use formz model to validate name and description

  bool validate({force = false}) {
    if (this.mounted) {
      widget.nextAction(next);
      if (force || !_nameFocusNode.hasFocus) {
        setState(() {
          errorText = null;
          if (_walletName.isEmpty) {
            _walletName = defaultWalletName!;
          }
        });
      }
    }
    return errorText != null ? false : true;
  }

  Widget _buildWalletDetailsForm(theme) {
    _nameFocusNode.addListener(() => validate());
    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Name',
            style: theme.textTheme.subtitle2,
          ),
          SizedBox(height: 8),
          TextField(
            style: theme.textTheme.bodyText1,
            decoration: InputDecoration(
              hintText: 'My first million Wits',
              errorText: errorText,
            ),
            controller: _nameController,
            focusNode: _nameFocusNode,
            onSubmitted: (String value) => {
              // hide keyboard
              _descriptionFocusNode.requestFocus()
            },
            onChanged: (String value) {
              setState(() {
                _walletName = value;
              });
            },
          ),
          SizedBox(height: 16),
          Text(
            'Description',
            style: theme.textTheme.subtitle2,
          ),
          SizedBox(height: 8),
          TextField(
            style: theme.textTheme.bodyText1,
            textInputAction: TextInputAction.go,
            decoration: InputDecoration(
              hintText: 'I will keep these with me forever',
            ),
            focusNode: _descriptionFocusNode,
            controller: _descController,
            onSubmitted: (_value) => nextAction(),
            onChanged: (String value) {
              setState(() {
                _walletDescription = value;
              });
            },
          )
        ],
      ),
    );
  }

  Widget _buildInfoText(theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Identify your wallet',
          style: theme.textTheme.titleLarge, //Textstyle
        ), //Text
        SizedBox(
          height: 16,
        ),
        Text(
          'You can better keep track of your different wallets by giving each its own name and description.',
          style: theme.textTheme.bodyLarge, //Textstyle
        ), //Text
        SizedBox(
          height: 8,
        ), //SizedBox
        Text(
          'Wallet names make it easy to quickly change from one wallet to another. Wallet descriptions can be more elaborate and rather describe the purpose of a wallet or any other metadata.',
          style: theme.textTheme.bodyLarge, //Textstyle
        ),
        SizedBox(
          height: 16,
        ), //SizedBox
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoText(theme),
          _buildWalletDetailsForm(theme),
        ]);
  }
}
