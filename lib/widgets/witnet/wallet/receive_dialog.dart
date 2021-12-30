import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:witnet_wallet/util/storage/database/db_wallet.dart';
import 'package:witnet_wallet/widgets/auto_size_text.dart';
import 'package:witnet_wallet/widgets/qr/qr_address_generator.dart';
import 'package:witnet_wallet/widgets/round_button.dart';

class ReceiveDialogBox extends StatefulWidget {
  final DbWallet dbWallet;
  ReceiveDialogBox({required this.dbWallet,});

  @override
  State<ReceiveDialogBox> createState() => ReceiveDialogBoxState();
}

class ReceiveDialogBoxState extends State<ReceiveDialogBox>
    with SingleTickerProviderStateMixin {
  String nextAddress = '';
  late AnimationController _loadingController;
  @override
  void initState() {
    super.initState();

    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    bool foundAddress = false;
    for (int i = widget.dbWallet.externalAccounts.length-1; i >= 0; i--) {
      if (nextAddress == '') {

        if(!foundAddress){
          if (widget.dbWallet.externalAccounts[i]!.utxos.isNotEmpty) {
            foundAddress = true;
            nextAddress =widget.dbWallet.externalAccounts[i+1]!.address;
          }
        }

      }
    }
    _loadingController.forward();
  }

  Widget contentBox(BuildContext context) {
    return SizedBox(
      child: Wrap(
        children: [
          Container(
            padding: EdgeInsets.all(5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    RoundButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Text(
                        'X',
                        style: TextStyle(fontSize: 33),
                      ),
                      loadingController: _loadingController,
                      label: '',
                      size: 25,
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                QrAddressGenerator(
                  data: nextAddress,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                        flex: 9,
                        child: Container(
                          child: AutoSizeText(
                            nextAddress,
                            style: TextStyle(fontWeight: FontWeight.w700),
                            maxLines: 1,
                            minFontSize: 9,
                          ),
                        )),
                    Expanded(
                        flex: 1,
                        child: Container(
                          child: IconButton(
                              iconSize: 15,
                              onPressed: () {
                                Clipboard.setData(
                                    ClipboardData(text: nextAddress));
                              },
                              icon: Icon(FontAwesomeIcons.copy)),
                        ))
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        insetPadding: EdgeInsets.all(0),
        elevation: 0,
        child: contentBox(context));
  }
}
