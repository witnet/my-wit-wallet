import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:witnet/data_structures.dart';
import 'package:witnet/utils.dart';
import 'package:witnet_wallet/bloc/create_vtt/create_vtt_bloc.dart';
import 'package:witnet_wallet/util/paddings.dart';
import 'package:witnet_wallet/util/witnet/wallet/account.dart';
import 'package:witnet_wallet/widgets/auto_size_text.dart';
import 'package:witnet_wallet/widgets/witnet/transactions/value_transfer/create_dialog_box/recipient_address_input.dart';
import 'package:witnet_wallet/widgets/witnet/transactions/value_transfer/create_dialog_box/vtt_stepper.dart';

import '../../../../round_button.dart';
import '../../../../toggle_switch.dart';

class CreateVTTDialogBox extends StatefulWidget {
  CreateVTTDialogBox({
    required this.externalAccounts,
    required this.internalAccounts,
  });
  final Map<String, Account> externalAccounts;
  final Map<String, Account> internalAccounts;

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
        print(_scrollController.position);
        if (_scrollController.position.pixels == 0) {
          // You're at the top.
        } else {
          scrolledToBottom = true;
          print('Bottom!');
        }
      }
    });
    _nameController = TextEditingController();
    _descController = TextEditingController();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    widget.externalAccounts.forEach((key, value) {
      Account account = value;
      print(value.jsonMap());
      print(account.valueTransfers);
      account.setBalance();
      print(account.utxos);
      availableFunds += account.balance;
    });
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
      height: 180,
      child: Wrap(
        children: [
          Container(
            height: deviceSize.height * 0.7,
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
                    children: [
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: AutoSizeText(
                          'Send Value Transfer Transaction',
                          maxLines: 1,
                          minFontSize: 14,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: theme.primaryColorDark),
                        ),
                      ),
                      RoundButton(
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
                    ],
                  ),
                  _buildDisclaimerTextScrollView(theme, deviceSize),
                ]),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimerTextScrollView(ThemeData theme, Size deviceSize) {
    return Container(
      decoration: BoxDecoration(),
      height: deviceSize.height * 0.6 - 5,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(0),
          child: Column(
            children: [
              VttStepper(
                externalAccounts: widget.externalAccounts,
                internalAccounts: widget.internalAccounts,
              ),

              SizedBox(
                height: 10,
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
      child: Container(
          decoration: BoxDecoration(),
          height: deviceSize.height * 0.7,
          child: contentBox(context)),
    );
  }
}
