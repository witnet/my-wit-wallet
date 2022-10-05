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

  String _walletName = '';
  String _walletDescription = '';
  void setWalletName(String walletName) {
    setState(() {
      _walletName = walletName;
    });
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descController = TextEditingController();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.prevAction(prev));
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.nextAction(next));
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _descController.dispose();
  }

  Widget _buildUserField() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            decoration: InputDecoration(labelText: 'Wallet Name'),
            controller: _nameController,
            onSubmitted: (String value) => null,
            onChanged: (String value) {
              setState(() {
                _walletName = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          TextField(
            decoration: InputDecoration(labelText: 'Wallet Description'),
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

  Widget _buildInfoText() {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          'Identify your Wallet',
          style: theme.textTheme.headline3, //Textstyle
        ), //Text
        SizedBox(
          height: 10,
        ),
        Text(
          'Keep track of and describe your Witnet wallet by filling in the boxes below.',
          style: theme.textTheme.bodyText1, //Textstyle
        ), //Text
        SizedBox(
          height: 10,
        ),
        SizedBox(height: 10), //SizedBox
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      _buildInfoText(),
      _buildUserField(),
      _buildDescriptionField(),
    ]);
  }
}
