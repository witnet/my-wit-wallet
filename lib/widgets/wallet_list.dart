import 'package:flutter/material.dart';

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

  DropdownMenuItem<String> _buildWalletDropdownItem(String value) {
    return DropdownMenuItem<String>(
      value: value,
      child: Text(value),
    );
  }

  void populateData() {
    widget.walletFiles.forEach((element) {
      files.add(ListItem('$element'));
    });
  }

  Widget _buildDropDownView(BuildContext context, ThemeData theme) {
    return DropdownButton<String>(
      isExpanded: true,
      focusColor: Colors.white,
      value: selectedWallet,
      //elevation: 5,
      items: widget.walletFiles.map<DropdownMenuItem<String>>((String value) {
        return _buildWalletDropdownItem(value);
      }).toList(),
      hint: Text(
        "Please choose wallet",
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      onChanged: (String? value) {
        setState(() {
          selectedWallet = value!;
          walletSelected = true;
        });
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
