import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:witnet/explorer.dart';
import 'package:witnet/schema.dart';
import 'package:witnet_wallet/util/paddings.dart';
import 'package:witnet_wallet/widgets/auto_size_text.dart';


class InputList {}

String formatDate(int ts) {
  DateTime dt = DateTime.fromMillisecondsSinceEpoch(ts * 1000);
  final f = new DateFormat('yyyy-MM-dd hh:mm:ss');
  //String _date = '${dt.year} ${dt.month} ${dt.day} ${dt.hour}:${dt.minute}:${dt.second}';

  return f.format(dt);
}

String truncateHash(String data) {
  return '${data.substring(0, 6)}...${data.substring(data.length - 6)}';
}
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
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

Widget _buildDisclaimerTextScrollView(BuildContext context,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Transaction ID',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: vti.txnHash));
                  },
                  icon: Icon(FontAwesomeIcons.copy),
                ),
              ],
            ),
            AutoSizeText('${vti.txnHash}',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
                maxLines: 2,
                minFontSize: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Status: ${vti.status}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),

          ],
        ),
      ),
    ),
  );
}

class VTTDialogBox extends StatelessWidget {
  final ValueTransferInfo vti;

  const VTTDialogBox({
    Key? key,
    required this.vti,
  }) : super(key: key);

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
              Text(
                formatDate(vti.txnTime),
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              _buildDisclaimerTextScrollView(context, vti, theme, deviceSize),
              SizedBox(
                height: 5,
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'BACK',
                      style: TextStyle(fontSize: 18),
                    )),
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
