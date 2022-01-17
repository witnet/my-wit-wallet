import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet/data_structures.dart';
import 'package:witnet/utils.dart';
import 'package:witnet_wallet/bloc/transactions/value_transfer/create_vtt_bloc.dart';
import 'package:witnet_wallet/util/paddings.dart';
import 'package:witnet_wallet/util/storage/database/db_wallet.dart';
import 'package:witnet_wallet/util/witnet/wallet/account.dart';
import 'package:witnet_wallet/widgets/auto_size_text.dart';
import 'package:witnet_wallet/widgets/witnet/transactions/value_transfer/create_dialog_box/vtt_stepper.dart';

import '../../../../round_button.dart';

class CreateVTTDialogBox extends StatefulWidget {
  CreateVTTDialogBox({
    required this.dbWallet,
  });
  final DbWallet dbWallet;

  @override
  CreateVTTDialogBoxState createState() => CreateVTTDialogBoxState();
}

class CreateVTTDialogBoxState extends State<CreateVTTDialogBox>
    with TickerProviderStateMixin {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late AnimationController _loadingController;
  late ScrollController _scrollController;
  bool scrolledToBottom = false;
  int availableFunds = 0;
  Map<String, List<Utxo>> utxoPool = {};
  List<String> requiredSignerPaths = [];
  Map<String, List<Utxo>> selectedUtxos = {};
  List<String> recipients = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge) {
        if (_scrollController.position.pixels == 0) {
          // You're at the top.
        } else {
          scrolledToBottom = true;
        }
      }
    });
    _nameController = TextEditingController();
    _descController = TextEditingController();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    availableFunds = widget.dbWallet.balanceNanoWit();
    _loadingController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  Widget contentBox(context) {
    final deviceSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final double cardWidth =
        (deviceSize.width < 600.0) ? deviceSize.width : 600;
    return SizedBox(
      child: Wrap(
        children: <Widget>[
          Container(
            height: deviceSize.height,
            alignment: Alignment.topCenter,
            margin: EdgeInsets.zero,
            width: cardWidth,
            padding: Paddings.fromLTR(5),
            decoration: BoxDecoration(color: theme.cardColor),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Expanded(
                      flex: 9,
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: AutoSizeText(
                          'Value Transfer Transaction ',
                          maxLines: 1,
                          minFontSize: 14,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: theme.primaryColor),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: RoundButton(
                        onPressed: () {
                          BlocProvider.of<BlocCreateVTT>(context)
                              .add(ResetTransactionEvent());
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
                    ),
                  ],
                ),
                _buildVttForm(theme, deviceSize),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVttForm(ThemeData theme, Size deviceSize) {
    return Container(
      decoration: BoxDecoration(),
      height: deviceSize.height * 0.8,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(0),
          child: Column(
            children: [
              VttStepper(
                dbWallet: widget.dbWallet,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Dialog(
      insetPadding: EdgeInsets.all(0),
      elevation: 0,
      child: new GestureDetector(
        onTap: () {
/*This method here will hide the soft keyboard.*/
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Container(
            decoration: BoxDecoration(),
            height: deviceSize.height,
            child: contentBox(context)),
      ),
    );
  }
}
