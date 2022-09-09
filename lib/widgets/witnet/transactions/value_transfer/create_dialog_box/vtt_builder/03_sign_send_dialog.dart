import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:witnet/schema.dart';
import 'package:witnet_wallet/bloc/explorer/explorer_bloc.dart';
import 'package:witnet_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';
import 'package:witnet_wallet/bloc/transactions/value_transfer/vtt_status/vtt_status_bloc.dart';
import 'package:witnet_wallet/widgets/auto_size_text.dart';

import '../../../../../input_login.dart';
import '../../../../../round_button.dart';

class SignSendDialog extends StatefulWidget {
  final VTTransactionBody vtTransactionBody;
  SignSendDialog({required this.vtTransactionBody});
  @override
  State<StatefulWidget> createState() => SignSendDialogState();
}

launchExplorerSearch(String searchItem) async {
  String url = 'https://witnet.network/search/$searchItem';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    BlocProvider.of<VTTCreateBloc>(context).add(SignTransactionEvent(
        password: _passController.text,
        vtTransactionBody: widget.vtTransactionBody));
  }

  ///
  void send(VTTransaction vtTransaction) {
    BlocProvider.of<VTTCreateBloc>(context)
        .add(SendTransactionEvent(vtTransaction));
  }

  void queryHash(String transactionHash) {
    BlocProvider.of<BlocStatusVtt>(context)
        .add(CheckStatusEvent(transactionHash: transactionHash));
  }

  void backToDashboard() {
    BlocProvider.of<VTTCreateBloc>(context).add(ResetTransactionEvent());
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    if(sent){
      BlocProvider.of<ExplorerBloc>(context).add(SyncWalletEvent(ExplorerStatus.dataloading));
    }
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
    return BlocBuilder<ExplorerBloc, ExplorerState>(builder: (context, state) {
      return Container(
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.end, children: []),
        ]),
      );
    });
  }

  Widget vtBlocContainer() {
    return BlocConsumer<VTTCreateBloc, VTTCreateState>(
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
            if (state.vttCreateStatus == VTTCreateStatus.building)
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
            if (state.vttCreateStatus == VTTCreateStatus.exception)
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
            if (state.vttCreateStatus == VTTCreateStatus.signing)
              Container(
                child: Column(
                  children: [Text('Signing Transaction')],
                ),
              ),
            if (state.vttCreateStatus == VTTCreateStatus.finished)
              Container(
                child: Column(
                  children: [
                    buildTransactionJsonViewer(context, state.vtTransaction),
                    SizedBox(
                      height: 5,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(FontAwesomeIcons.arrowRight),
                        ElevatedButton(
                            onPressed: () {

                              // print(state.vtTransaction.jsonMap(asHex: true));
                              send(state.vtTransaction);
                            },
                            child: Text('Send To Explorer')),
                      ],
                    )
                  ],
                ),
              ),
            if (state.vttCreateStatus == VTTCreateStatus.sending)
              Container(
                child: Column(
                  children: [],
                ),
              ),
            if (state.vttCreateStatus == VTTCreateStatus.accepted)
              Container(
                child: Column(
                  children: [
                    AutoSizeText('Transaction Sent!',maxLines: 1,),
                    buildTransactionJsonViewer(context, state.vtTransaction),
                    SizedBox(
                      height: 5,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(FontAwesomeIcons.arrowRight),
                        ElevatedButton(
                            onPressed: () {
                              /// Launch the Explorer in the machines default browser
                              launchExplorerSearch(state.vtTransaction.transactionID);
                            },
                            child: Text('View on Explorer')),
                      ],
                    )
                  ],
                ),
              )
          ],
        ),
      );
    },
    listener: (context, state) {
          if(state.vttCreateStatus == VTTCreateStatus.accepted){
            setState(() {
              sent = true;
            });
          }
    },
    );
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
