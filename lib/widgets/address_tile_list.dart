import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wit_wallet/screens/create_wallet/create_wallet_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddressTileList extends StatefulWidget {
  final double width;
  final Function? onSelected;
  final List<String> addressList;
  const AddressTileList(
      {Key? key,
      required this.onSelected,
      required this.width,
      required this.addressList})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => AddressTileListState();
}

class AddressTileListState extends State<AddressTileList> {
  List files = [];
  late String selectedAddress;
  bool addressesExist = false;
  bool addressSelected = false;

  AppLocalizations get _localization => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    if (widget.addressList.length >= 1) addressesExist = true;
    selectedAddress = widget.addressList[0];
    addressSelected = true;
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
              child: new Text(_localization.createWalletLabel),
              onPressed: () {
                Navigator.pushNamed(context, CreateWalletScreen.route);
              },
            ),
          ),
        ],
      ),
    );
  }

  DropdownMenuItem buildWalletDropdownItem(String value) {
    return DropdownMenuItem<String>(
      value: value,
      child: Text(
        value,
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  String truncateAddress(String addr) {
    return addr.substring(0, 8) +
        '...' +
        addr.substring(addr.length - 4, addr.length);
  }

  Widget _buildTileList(BuildContext context, ThemeData theme) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.addressList.length,
      itemBuilder: (context, index) {
        return Card(
          color: Colors.black26,
          child: Column(children: [
            Text(
              '${widget.addressList[index]}',
              textScaleFactor: 0.97,
            ),
            ListTile(
              title: Text('${truncateAddress(widget.addressList[index])}'),
              leading: Icon(FontAwesomeIcons.wallet),
              trailing: Icon(FontAwesomeIcons.receipt),
            ),
          ]),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget _base;
    if (addressesExist) {
      _base = _buildTileList(context, theme);
    } else {
      _base = _buildInitialButtons(context, theme);
    }
    return new Row(
      children: <Widget>[
        Expanded(
            child: SizedBox(
          height: 200.0,
          child: _base,
        )),
      ],
    );
  }
}
