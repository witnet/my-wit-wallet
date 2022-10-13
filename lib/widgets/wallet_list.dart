import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/api_create_wallet.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:witnet_wallet/screens/create_wallet/create_wallet_screen.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/widgets/PaddedButton.dart';
import 'package:witnet_wallet/widgets/select.dart';
import 'package:witnet_wallet/util/storage/path_provider_interface.dart';

class ListItem {
  bool isSelected = false;
  String data;

  ListItem(this.data);
}

class WalletList extends StatefulWidget {
  const WalletList({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => WalletListState();
}

class WalletListState extends State<WalletList> {
  List<String> walletList = [];
  late String selectedWallet = '';
  bool walletsExist = false;
  bool walletSelected = false;
  late Function onSelected;

  @override
  void initState() {
    super.initState();
    _getWallets();
  }

  void _getWallets() async {
    PathProviderInterface interface = PathProviderInterface();
    await interface.getWalletFiles().then((value) => {
          if (value.length > 0)
            {
              setState(() {
                walletList = value;
                selectedWallet = value[0];
              })
            }
        });
  }

    //Go to create or import wallet view
  void _createImportWallet() {
    Locator.instance<ApiCreateWallet>().setWalletType(WalletType.unset);
    Navigator.pushNamed(context, CreateWalletScreen.route);
    BlocProvider.of<CreateWalletBloc>(context)
        .add(ResetEvent(WalletType.unset));
  }

  Widget _buildInitialButtons() {
    return PaddedButton(
      padding: EdgeInsets.all(0), 
      text: 'New wallet', 
      onPressed: () => {
        _createImportWallet(),
      },
      type: 'text',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _buildInitialButtons(),
      Select(
          listItems: walletList,
          selectedItem: selectedWallet,
          onChanged: (String? value) => {
                setState(() {
                  selectedWallet = value!;
                  // Locator.instance.get<ApiAuth>().setWalletName(value);
                  walletSelected = true;
                })
              }),
    ]);
  }
}
