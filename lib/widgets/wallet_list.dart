import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:witnet_wallet/shared/api_auth.dart';
import 'package:witnet_wallet/shared/locator.dart';

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

  Widget _getListItemTile(BuildContext context, ThemeData theme, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          for (int i = 0; i < files.length; i++) {
            if (i == index) {
              files[i].isSelected = true;
              Locator.instance.get<ApiAuth>().setWalletName(files[i].data);
            } else {
              files[i].isSelected = false;
            }
          }
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 3),
        color: files[index].isSelected ? Colors.indigo : Colors.black26,
        child: ListTile(
          title: Column(
            children: [
              Text(files[index].data),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        print(index);
                      },
                      child: Text('Button'))
                ],
              ),
            ],
          ),
          leading: Icon(FontAwesomeIcons.wallet),
          trailing: Icon(FontAwesomeIcons.receipt),
        ),
      ),
    );
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
          Locator.instance.get<ApiAuth>().setWalletName(value);
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
