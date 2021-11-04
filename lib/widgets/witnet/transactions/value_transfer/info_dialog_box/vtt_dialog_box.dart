import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:witnet/explorer.dart';
import 'package:witnet/schema.dart';
import 'package:witnet/utils.dart';
import 'package:witnet_wallet/util/paddings.dart';
import 'package:witnet_wallet/widgets/auto_size_text.dart';

import '../../../../round_button.dart';

String formatDate(int ts) {
  DateTime dt = DateTime.fromMillisecondsSinceEpoch(ts * 1000);
  final f = new DateFormat('EEE yyyy-MM-dd hh:mm:ss');
  //String _date = '${dt.year} ${dt.month} ${dt.day} ${dt.hour}:${dt.minute}:${dt.second}';

  return f.format(dt);
}

String truncateHash(String data) {
  return '${data.substring(0, 6)}...${data.substring(data.length - 6)}';
}

class VTTDialogBox extends StatefulWidget {
  final ValueTransferInfo vti;

  const VTTDialogBox({
    Key? key,
    required this.vti,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => VttDialogBoxState();
}

class VttDialogBoxState extends State<VTTDialogBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _loadingController;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadingController.forward();
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  void backToDashboard(BuildContext context) {
    _loadingController.reverse();
    Navigator.of(context).pop();
  }

  //////////////////////////////////////////////////////////////////////////////
  Widget buildInputs(BuildContext context, ValueTransferInfo vti) {
    final theme = Theme.of(context);
    List<Widget> inputs = [];
    inputs.add(Row(children: [
      SizedBox(
        width: 5,
      ),
      AutoSizeText(
        'Inputs',
        textAlign: TextAlign.left,
      )
    ]));
    vti.inputs.forEach((element) {
      inputs.add(Row(
        children: [
          Expanded(
              flex: 1,
              child: Icon(
                FontAwesomeIcons.fileInvoice,
                color: theme.accentColor,
              )),
          Expanded(
              flex: 8,
              child: AutoSizeText(
                element.address,
                maxLines: 1,
                minFontSize: 9,
                textAlign: TextAlign.center,
              )),
          Expanded(
            flex: 1,
            child: IconButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: element.address));
              },
              icon: Icon(
                FontAwesomeIcons.copy,
                size: 15,
              ),
            ),
          ),
        ],
      ));
      inputs.add(Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
              flex: 8,
              child: AutoSizeText(
                nanoWitToWit(element.value).toStringAsFixed(9),
                textAlign: TextAlign.right,
                maxLines: 1,
                minFontSize: 9,
              )),
          SizedBox(
            width: 5,
          ),
          Expanded(
            flex: 1,
            child: Image.asset(
              'assets/img/favicon.ico',
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Expanded(
              flex: 1,
              child: AutoSizeText(
                'WIT',
                maxLines: 1,
                minFontSize: 9,
                textAlign: TextAlign.center,
              )),
        ],
      ));
    });
    return Container(child: Column(children: inputs));
  }

//////////////////////////////////////////////////////////////////////////////
  Widget buildOutputs(BuildContext context, ValueTransferInfo vti) {
    final theme = Theme.of(context);
    List<Widget> outputs = [];
    outputs.add(Row(children: [
      SizedBox(width: 5),
      AutoSizeText(
        'Outputs',
        textAlign: TextAlign.left,
      ),
    ]));
    vti.outputs.forEach((element) {
      outputs.add(Row(
        children: [
          Expanded(
              flex: 1,
              child: Icon(
                FontAwesomeIcons.addressCard,
                color: theme.accentColor,
              )),
          Expanded(
              flex: 8,
              child: AutoSizeText(
                element.pkh.address,
                maxLines: 1,
                minFontSize: 9,
                textAlign: TextAlign.center,
              )),
          Expanded(
            flex: 1,
            child: IconButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: element.pkh.address));
              },
              icon: Icon(
                FontAwesomeIcons.copy,
                size: 15,
              ),
            ),
          ),
        ],
      ));
      outputs.add(Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
              flex: 8,
              child: AutoSizeText(
                nanoWitToWit(element.value).toStringAsFixed(9),
                textAlign: TextAlign.right,
                maxLines: 1,
                minFontSize: 9,
              )),
          SizedBox(width: 5),
          Expanded(
            flex: 1,
            child: Image.asset(
              'assets/img/favicon.ico',
            ),
          ),
          SizedBox(width: 5),
          Expanded(
              flex: 1,
              child: AutoSizeText(
                'WIT',
                maxLines: 1,
                minFontSize: 9,
                textAlign: TextAlign.center,
              )),
        ],
      ));
    });
    return Container(child: Column(children: outputs));
  }

  Widget _buildDetailsContainer(BuildContext context, ValueTransferInfo vti) {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(flex: 1, child: AutoSizeText('Epoch:', maxLines: 1)),
              Expanded(
                  flex: 2,
                  child: AutoSizeText(vti.txnEpoch.toString(), maxLines: 1)),
              Expanded(flex: 1, child: AutoSizeText('Status:', maxLines: 1)),
              Expanded(flex: 2, child: AutoSizeText(vti.status, maxLines: 1)),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Expanded(
                  flex: 1,
                  child: AutoSizeText(
                    'Block:',
                    maxLines: 1,
                  )),
            ],
          ),
          Row(
            children: [
              Expanded(
                flex: 5,
                child: AutoSizeText(
                  vti.blockHash,
                  maxLines: 1,
                  minFontSize: 9,
                ),
              ),
              Expanded(
                flex: 1,
                child: IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: vti.blockHash));
                  },
                  icon: Icon(
                    FontAwesomeIcons.copy,
                    size: 15,
                  ),
                ),
              )
            ],
          ),
          Row(
            children: [
              Expanded(
                  flex: 3,
                  child: AutoSizeText(
                    'Transaction ID:',
                    maxLines: 1,
                  )),
            ],
          ),
          Row(
            children: [
              Expanded(
                flex: 8,
                child: AutoSizeText(
                  vti.txnHash,
                  maxLines: 1,
                  minFontSize: 9,
                ),
              ),
              Expanded(
                flex: 1,
                child: IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: vti.txnHash));
                  },
                  icon: Icon(
                    FontAwesomeIcons.copy,
                    size: 15,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeeContainer(BuildContext context, ValueTransferInfo vti) {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(flex: 1, child: AutoSizeText('Fee:', maxLines: 1)),
              Expanded(
                  flex: 8,
                  child: AutoSizeText(nanoWitToWit(vti.fee).toStringAsFixed(9),
                      textAlign: TextAlign.right, maxLines: 1)),
              SizedBox(
                width: 5,
              ),
              Expanded(
                flex: 1,
                child: Image.asset(
                  'assets/img/favicon.ico',
                ),
              ),
              SizedBox(width: 3),
              Expanded(
                  flex: 1,
                  child: AutoSizeText(
                    'WIT',
                    maxLines: 1,
                    minFontSize: 9,
                    textAlign: TextAlign.center,
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionDetailsContainer(BuildContext context,
      ValueTransferInfo vti, ThemeData theme, Size deviceSize) {
    return Container(
      height: deviceSize.height * 0.55,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Column(
            children: [
              SizedBox(
                height: 15,
              ),
              _buildDetailsContainer(context, vti),
              Container(
                decoration:
                    BoxDecoration(color: theme.primaryColor.withOpacity(.1)),
                child: Column(
                  children: [
                    buildInputs(context, vti),
                    buildOutputs(context, vti),
                  ],
                ),
              ),
              _buildFeeContainer(context, vti),
            ],
          ),
        ),
      ),
    );
  }

  contentBox(context) {
    final deviceSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    return Stack(
      children: <Widget>[
        Container(
          height: deviceSize.height * 0.7,
          alignment: Alignment.topCenter,
          margin: EdgeInsets.zero,
          width: (deviceSize.width < 600.0) ? deviceSize.width : 600,
          padding: Paddings.fromLTR(5),
          decoration: BoxDecoration(color: theme.cardColor),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    formatDate(widget.vti.txnTime),
                    maxLines: 1,
                    minFontSize: 10,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  RoundButton(
                    onPressed: () => backToDashboard(context),
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
              _buildTransactionDetailsContainer(
                  context, widget.vti, theme, deviceSize),
              SizedBox(
                height: 5,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(5),
      elevation: 0,
      child: contentBox(context),
    );
  }
}
