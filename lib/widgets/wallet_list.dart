import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/api_create_wallet.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:witnet_wallet/screens/create_wallet/create_wallet_screen.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/theme/colors.dart';
import 'package:witnet_wallet/theme/extended_theme.dart';
import 'package:witnet_wallet/widgets/PaddedButton.dart';
import 'package:witnet_wallet/util/storage/path_provider_interface.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ListItem {
  bool isSelected = false;
  String data;

  ListItem(this.data);
}

class WalletList extends StatefulWidget {
  const WalletList({
    Key? key,
  }) : super(
          key: key,
        );

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
      text: 'Add new',
      onPressed: () => {
        _createImportWallet(),
      },
      icon: Icon(
        FontAwesomeIcons.plusCircle,
        size: 18,
      ),
      type: 'horizontal-icon',
    );
  }

  Widget _buildWalletItem(walletName) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    final isSelectedWallet = walletName == selectedWallet;
    final textStyle = TextStyle(
        fontFamily: 'NotoSans',
        color: WitnetPallet.white,
        fontSize: 14,
        fontWeight: FontWeight.normal);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        child: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelectedWallet
                ? extendedTheme.walletActiveItemBackgroundColor
                : extendedTheme.walletListBackgroundColor,
            borderRadius: BorderRadius.all(Radius.circular(4)),
            border: Border.all(
              color: isSelectedWallet
                  ? extendedTheme.walletActiveItemBorderColor!
                  : extendedTheme.walletItemBorderColor!,
              width: 1,
            ),
          ),
          margin: EdgeInsets.all(8),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(
              color: extendedTheme.selectedTextColor,
              width: 30,
              height: 30,
            ),
            Column(
              children: [
                Text(
                  walletName,
                  style: textStyle,
                ),
                Text(
                  'wit1...113',
                  style: textStyle,
                ),
              ],
            ),
            Text(
              '0.00 Wit',
              style: textStyle,
            ),
          ]),
        ),
        onTap: () {
          setState(() {
            selectedWallet = walletName!;
            // Locator.instance.get<ApiAuth>().setWalletName(value);
            walletSelected = true;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(padding: EdgeInsets.all(8), children: [
      Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [_buildInitialButtons()]),
      ListView.builder(
        shrinkWrap: true,
        itemCount: walletList.length,
        itemBuilder: (context, index) {
          return _buildWalletItem(walletList[index]);
        },
      ),
    ]);
  }
}
