import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:witnet/explorer.dart';
import 'package:witnet/utils.dart';
import 'package:witnet_wallet/util/storage/cache/transaction_cache.dart';
import 'package:witnet_wallet/widgets/auto_size_text.dart';
import 'package:witnet_wallet/widgets/witnet/transactions/value_transfer/info_dialog_box/vtt_dialog_box.dart';

import '../util/storage/database/account.dart';


String formatDate(int ts) {
  DateTime dt = DateTime.fromMillisecondsSinceEpoch(ts * 1000);
  final f = new DateFormat('yyyy-MM-dd hh:mm:ss');
  //String _date = '${dt.year} ${dt.month} ${dt.day} ${dt.hour}:${dt.minute}:${dt.second}';
  return f.format(dt);
}

Widget buildInputs(ValueTransferInfo vti) {
  List<Widget> inputs = [];
  vti.inputs.forEach((element) {
    inputs.add(Card(
      child: Padding(
        padding: EdgeInsets.all(5),
        child: Column(
          children: [
            Text('Address:    ${element.address}',
                style: TextStyle(
                  fontSize: 14,
                )),
            Text(
                '${element.input.outputPointer.transactionId.hex}:${element.input.outputPointer.outputIndex} Value: ${element.value}',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500))
          ],
        ),
      ),
    ));
    inputs.add(SizedBox(
      height: 3,
    ));
  });

  return Column(children: inputs);
}

Widget buildOutputs(ValueTransferInfo vti) {
  List<Widget> inputs = [];
  vti.outputs.forEach((element) {
    inputs.add(Text(
      '${element.pkh.address}',
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ));
    inputs.add(Text(' Value: ${element.value}'));
    inputs.add(Text(' TimeLock: ${element.timeLock}'));
  });

  return Column(children: inputs);
}

class VttListItem {
  ValueTransferInfo valueTransferInfo;

  VttListItem(this.valueTransferInfo);
}

class VttListWidget extends StatefulWidget {
  final double width;
  final Map<String, Account> accounts;

  @override
  VttListWidgetState createState() => VttListWidgetState();

  VttListWidget({
    Key? key,
    required this.width,
    required this.accounts,
  }) : super(key: key);
}

String formatBalance(int value) {
  double wit = nanoWitToWit(value);
  if (wit > 1.0) {
    return '${wit.toStringAsPrecision(9)} WIT';
  }
  return '${value.toString()} nWIT';
}

class VttListWidgetState extends State<VttListWidget> {
  List<VttListItem> transactions = [];
  late ValueTransferInfo? currentTransaction;
  bool emptyList = true;
  FocusNode focusNode = FocusNode();
  List<String> addresses = [];
  @override
  void initState() {
    super.initState();

    Map<String, VttListItem> trx = {};
    widget.accounts.forEach((path, account) {
      addresses.add(account.address);
      account.vttHashes.forEach((vttHash) {
        TransactionCache cache = TransactionCache();
        if (!trx.containsKey(vttHash)) trx[vttHash] = VttListItem(cache.getVtt(vttHash));
      });
    });
    transactions = sortTransactions(trx.values.toList());

    if (transactions.length > 1) {
      emptyList = false;
      currentTransaction = transactions.first.valueTransferInfo;
    }
  }

  bool receiver(ValueTransferInfo vti) {
    bool _receiver = false;
    vti.outputs.forEach((element) {
      if (addresses.contains(element.pkh.address)) {
        _receiver = true;
      }
    });
    return _receiver;
  }

  bool sender(ValueTransferInfo vti) {
    bool _sender = false;
    vti.inputs.forEach((element) {
      if (addresses.contains(element.address)) {
        _sender = true;
      }
    });
    return _sender;
  }

  List<int> getTimeList() {
    List<int> times = [];
    transactions.forEach((element) {
      ValueTransferInfo vti = element.valueTransferInfo;
      times.add(vti.txnTime);
    });
    return times;
  }

  int receiveValue(ValueTransferInfo vti) {
    int nanoWitvalue = 0;
    vti.outputs.forEach((element) {
      if (addresses.contains(element.pkh.address)) {
        nanoWitvalue += element.value.toInt();
      }
    });
    return nanoWitvalue;
  }

  int sendValue(ValueTransferInfo vti) {
    int value = 0;
    vti.inputs.forEach((element) {
      if (addresses.contains(element.address)) {
        value += element.value;
      }
    });
    return value;
  }

  int trxValue(ValueTransferInfo vti) {
    int value = 0;
    vti.outputs.forEach((element) {
      if (addresses.contains(element.pkh.address)) {
        value += element.value.toInt();
      }
    });
    return value;
  }

  Future<void> _showVTTDialog() async {
    ValueTransferInfo vti = currentTransaction!;

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return VTTDialogBox(
          vti: vti,
        );
      },
    );
  }

  Widget buildTrxTile(ValueTransferInfo vti, int index) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          sender(vti) ? Icon(FontAwesomeIcons.arrowUp) : Text(''),
          receiver(vti) ? Icon(FontAwesomeIcons.arrowDown) : Text(''),
        ],
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: AutoSizeText(
              '${formatDate(vti.txnTime)}',
              maxLines: 1,
            ),
          ),
        ],
      ),
      subtitle: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: receiver(vti)
                  ? AutoSizeText(
                      ' + ${formatBalance(receiveValue(vti))}',
                      maxLines: 1,
                      minFontSize: 3,
                    )
                  : AutoSizeText(
                      ' - ${formatBalance(sendValue(vti))}',
                      maxLines: 1,
                      minFontSize: 3,
                    ),
            ),
          ]),
      trailing: IconButton(
          onPressed: _showVTTDialog, icon: Icon(FontAwesomeIcons.info)),
      onTap: _showVTTDialog,
      focusNode: focusNode,
      hoverColor: theme.primaryColor.withOpacity(.2),
    );
  }

  List<VttListItem> sortTransactions(List<VttListItem> data) {
    List<VttListItem> sortedTransactions = data
      ..sort((e1, e2) {
        ValueTransferInfo vti1 = e1.valueTransferInfo;
        ValueTransferInfo vti2 = e2.valueTransferInfo;
        var diff = vti2.txnTime.compareTo(vti1.txnTime);
        if (diff == 0) diff = vti2.txnTime.compareTo(vti1.txnTime);
        return diff;
      });
    return sortedTransactions;
  }

  Widget _build(BuildContext context) {
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, int index) {
        ValueTransferInfo vti = transactions[index].valueTransferInfo;
        return MouseRegion(
            onHover: (PointerEvent details) {
              setState(() {
                currentTransaction = vti;
              });
            },
            child: buildTrxTile(vti, index));
      },
      addRepaintBoundaries: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    if (emptyList) {
      return SingleChildScrollView(
        // <- added
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: min(deviceSize.width * 0.95, 600.0),
              height: 200,
              child: Text('No Transactions'),
            ),
          ],
        ),
      );
    } else {
      return SingleChildScrollView(
        // <- added
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
                width: min(deviceSize.width * 0.95, 600.0),
                height: deviceSize.height * 0.6,
                child: _build(context)),
          ],
        ),
      );
    }
  }
}
