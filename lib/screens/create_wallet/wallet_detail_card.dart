import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/api_create_wallet.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'bloc/create_wallet_bloc.dart';

typedef void FunctionCallback(Function? value);

class WalletDetailCard extends StatefulWidget {
  final Function nextAction;
  final Function prevAction;
  WalletDetailCard({
    Key? key,
    required FunctionCallback this.nextAction,
    required FunctionCallback this.prevAction,
  }) : super(key: key);
  WalletDetailCardState createState() => WalletDetailCardState();
}

class WalletDetailCardState extends State<WalletDetailCard>
    with TickerProviderStateMixin {
  void prev() {
    WalletType type =
        BlocProvider.of<CreateWalletBloc>(context).state.walletType;
    BlocProvider.of<CreateWalletBloc>(context).add(PreviousCardEvent(type));
  }

  void next() {
    Locator.instance.get<ApiCreateWallet>().setWalletName(_walletName);
    Locator.instance
        .get<ApiCreateWallet>()
        .setWalletDescription(_walletDescription);
    WalletType type =
        BlocProvider.of<CreateWalletBloc>(context).state.walletType;
    BlocProvider.of<CreateWalletBloc>(context)
        .add(NextCardEvent(type, data: {}));
  }

  late TextEditingController _nameController;
  late TextEditingController _descController;
  final _nameFocusNode = FocusNode();
  String _walletName = '';
  String _walletDescription = '';
  bool _hasInputError = false;
  String errorText = 'Password mismatch';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descController = TextEditingController();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.prevAction(prev));
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _descController.dispose();
  }

  final _formKey = GlobalKey<FormState>();

  void setValidation() {
    if (!_nameFocusNode.hasFocus) {
      if (_walletName.isEmpty) {
        widget.nextAction(null);
        setState(() {
          _hasInputError = true;
          errorText = 'Please add a name for your wallet';
        });
      } else {
        setState(() {
          _hasInputError = false;
        });
        widget.nextAction(next);
      }
    } else if (_walletName.isEmpty) {
      widget.nextAction(null);
    }
  }

  Widget _buildWalletDetailsForm(theme) {
    _nameFocusNode.addListener(() => setValidation());
    return Form(
      key: _formKey,
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
            decoration: InputDecoration(
              hintText: 'Wallet Name',
              errorText: _hasInputError ? errorText : null,
            ),
            controller: _nameController,
            focusNode: _nameFocusNode,
            onSubmitted: (String value) => null,
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
            decoration: InputDecoration(
              hintText: 'Wallet Description',
            ),
            controller: _descController,
            onSubmitted: (String value) => null,
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
          'Identify your Wallet',
          style: theme.textTheme.headline3, //Textstyle
        ), //Text
        SizedBox(
          height: 16,
        ),
        Text(
          'Keep track of and describe your Witnet wallet by filling in the boxes below.',
          style: theme.textTheme.bodyText1, //Textstyle
        ), //Text
        SizedBox(
          height: 16,
        ), //SizedBox
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      _buildInfoText(theme),
      _buildWalletDetailsForm(theme),
    ]);
  }
}
