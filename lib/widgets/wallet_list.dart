import 'package:flutter/material.dart';
import 'package:witnet_wallet/shared/api_auth.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/widgets/select.dart';

class ListItem {
  bool isSelected = false;
  String data;

  ListItem(this.data);
}

class WalletListWidget extends StatefulWidget {
  final double width;
  final List<String> walletFiles;

  const WalletListWidget(
      {Key? key, required this.width, required this.walletFiles})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => WalletListWidgetState();
}

class WalletListWidgetState extends State<WalletListWidget> {
  List<ListItem> files = [];
  late String selectedWallet;
  bool walletsExist = false;
  bool walletSelected = false;
  late Function onSelected;

  @override
  void initState() {
    super.initState();
    if (widget.walletFiles.length >= 1) walletsExist = true;
    selectedWallet = widget.walletFiles[0];
    Locator.instance.get<ApiAuth>().setWalletName(selectedWallet);
    walletSelected = true;
    populateData();
  }

  Widget _buildInitialButtons(BuildContext context, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.all(5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: ElevatedButton(
              child: new Text('Create Wallet'),
              onPressed: () {
                Navigator.pushNamed(context, '/create_wallet');
              },
            ),
          ),
        ],
      ),
    );
  }

  void populateData() {
    widget.walletFiles.forEach((element) {
      files.add(ListItem('$element'));
    });
  }

  Widget _buildDropDownView(BuildContext context, ThemeData theme) {
    return Select(
      listItems: widget.walletFiles,
      selectedItem: selectedWallet,
      onChanged: (String? value) => {
        setState(() {
          selectedWallet = value!;
          Locator.instance.get<ApiAuth>().setWalletName(value);
          walletSelected = true;
        })
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget _base;
    if (walletsExist) {
      _base = _buildDropDownView(context, theme);
    } else {
      _base = _buildInitialButtons(context, theme);
    }
    return new Row(
      children: <Widget>[
        Expanded(
          child: _base,
        )
      ],
    );
  }
}
