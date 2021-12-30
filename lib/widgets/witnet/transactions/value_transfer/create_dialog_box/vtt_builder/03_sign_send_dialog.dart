
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:witnet/schema.dart';
import 'package:witnet_wallet/bloc/explorer/explorer_bloc.dart';
import 'package:witnet_wallet/bloc/transactions/value_transfer/create_vtt_bloc.dart';
import 'package:witnet_wallet/widgets/auto_size_text.dart';

import '../../../../../input_login.dart';
import '../../../../../round_button.dart';

class SignSendDialog extends StatefulWidget {
  final VTTransactionBody vtTransactionBody;
  SignSendDialog({required this.vtTransactionBody});
  @override
  State<StatefulWidget> createState() => SignSendDialogState();
}

class SignSendDialogState extends State<SignSendDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _loadingController;
  late TextEditingController _passController;
  late FocusNode _passwordFocusNode;
  String password = '';

  bool sent = false;
  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _passController = TextEditingController();
    _passwordFocusNode = FocusNode();
    _passController.text = '';
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_passwordFocusNode);
    });

    _loadingController.forward();
  }

  @override
  void dispose() {
    super.dispose();
    _loadingController.dispose();
    _passController.dispose();
    _passwordFocusNode.dispose();
  }

  void sign() {
    BlocProvider.of<BlocCreateVTT>(context).add(SignTransactionEvent(
        password: _passController.text,
        vtTransactionBody: widget.vtTransactionBody));
  }

  void send(VTTransaction vtTransaction) {
    BlocProvider.of<BlocCreateVTT>(context)
        .add(SendTransactionEvent(vtTransaction));
  }

  void backToDashboard() {
    BlocProvider.of<BlocCreateVTT>(context).add(ResetTransactionEvent());
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  Widget buildTransactionJsonViewer(
      BuildContext context, VTTransaction vtTransaction) {
    final deviceSize = MediaQuery.of(context).size;

    return Container(
      height: deviceSize.height * 0.5,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'Transaction ID:',
                    textAlign: TextAlign.left,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(
                          ClipboardData(text: vtTransaction.transactionID));
                    },
                    icon: Icon(FontAwesomeIcons.copy),
                  ),
                ],
              ),
              AutoSizeText(
                vtTransaction.transactionID,
                maxLines: 1,
                minFontSize: 9,
              ),
              Row(
                children: [
                  Text(
                    'JSON Data:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(
                          text: vtTransaction.rawJson(asHex: true)));
                    },
                    icon: Icon(FontAwesomeIcons.copy),
                  ),
                ],
              ),
              //Text(vtTransaction.rawJson(asHex: true)),
              SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget explorerBlocContainer() {
    return BlocBuilder<BlocExplorer, ExplorerState>(builder: (context, state) {
      return Container(
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.end, children: []),
        ]),
      );
    });
  }

  Widget vtBlocContainer() {
    return BlocBuilder<BlocCreateVTT, CreateVTTState>(
        builder: (context, state) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                RoundButton(
                  onPressed: backToDashboard,
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
            if (state is BuildingVTTState)
              Container(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(7),
                      child: AutoSizeText(
                        'Password is required to sign the transaction.',
                        maxLines: 2,
                        minFontSize: 9,
                      ),
                    ),
                    InputLogin(
                      prefixIcon: Icons.lock,
                      hint: 'Password',
                      obscureText: true,
                      textEditingController: _passController,
                      focusNode: _passwordFocusNode,
                      onChanged: (String? value) {
                        setState(() {
                          password = value!;
                        });
                      },
                    ),
                    SizedBox(
                      height: 7,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(onPressed: sign, child: Text('Sign'))
                      ],
                    )
                  ],
                ),
              ),
            if (state is ErrorState)
              Container(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(7),
                      child: AutoSizeText(
                        'Password is required to sign the transaction.',
                        maxLines: 2,
                        minFontSize: 9,
                      ),
                    ),
                    InputLogin(
                      prefixIcon: Icons.lock,
                      hint: 'Password',
                      obscureText: true,
                      textEditingController: _passController,
                      focusNode: _passwordFocusNode,
                      onChanged: (String? value) {
                        setState(() {
                          password = value!;
                        });
                      },
                    ),
                    AutoSizeText(
                      'ERROR: Incorrect Password.',
                      maxLines: 2,
                      minFontSize: 9,
                    ),
                    SizedBox(
                      height: 7,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(onPressed: sign, child: Text('Sign'))
                      ],
                    )
                  ],
                ),
              ),
            if (state is SigningState)
              Container(
                child: Column(
                  children: [Text('Signing Transaction')],
                ),
              ),
            if (state is FinishState)
              Container(
                child: Column(
                  children: [
                    buildTransactionJsonViewer(context, state.vtTransaction),
                    SizedBox(
                      height: 5,
                    ),
                    (sent) 
                        ?Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [AutoSizeText('Sent!')])
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(FontAwesomeIcons.arrowRight),
                        ElevatedButton(
                            onPressed: () {
                            //onPressed: () {
                              print(state.vtTransaction.jsonMap(asHex: true));
                              send(state.vtTransaction);
                            },
                            child: Text('Send To Explorer')),
                      ],
                    )
                  ],
                ),
              ),
            if (state is SendingState)
              Container(
                child: Column(
                  children: [],
                ),
              )
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    double cardWidth;
    if (deviceSize.width > 400) {
      cardWidth = (400 * 0.8);
    } else
      cardWidth = deviceSize.width;

    return Dialog(
      insetPadding: EdgeInsets.all(0),
      child: Container(
        width: cardWidth,
        height: deviceSize.height * 0.8,
        padding: EdgeInsets.all(7),
        child: Column(
          children: [
            vtBlocContainer(),
          ],
        ),
      ),
    );
  }
}
/*
{"transaction":{"ValueTransfer":{"body":{"inputs":[{"output_pointer":"3c3a5cb5bf82c3cc0e239c8c22a2f1ed8398ff7980f7a7cf7c6b2e33aa973664:1"}],"outputs":[{"pkh":"wit1p0tdyrujhhadpvtqp4v4u3xpmf4mfn2af0k5yg","time_lock":0,"value":1200000},{"pkh":"wit1x0rknjj87plj489cumtqwr3fj2r92u2tyrujde","time_lock":0,"value":998799997}]},"signatures":[{"public_key":{"bytes":"0d8029c4cc4dfb30f89af81634b61e812486d91442cb931802a9d5e7c5ff0100","compressed":2},"signature":{"Secp256k1":{"der":"304502210083d5abe4cf5cf8e3bc1a4853f514230b05b0032da39511f842c3ee47de51b58302205e9e8f3b8fd66bc3e6c7219b6e35c34a686d21a19a02cb9a2ded98eb24b561fa"}}}]}}}
 */