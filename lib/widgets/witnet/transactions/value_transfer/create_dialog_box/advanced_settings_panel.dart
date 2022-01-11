import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../auto_size_text.dart';
import '../../fee_type_selector_chip.dart';

class AdvancedVttSettingsPanel extends StatefulWidget {
  @override
  State<AdvancedVttSettingsPanel> createState() =>
      AdvancedVttSettingsPanelState();
}

class AdvancedVttSettingsPanelState extends State<AdvancedVttSettingsPanel> {
  bool _isOpenMain = false;
  int timeLock = 0;
  late TextEditingController _timeLockController;
  @override
  void initState() {
    super.initState();

    _timeLockController = TextEditingController();
  }

  Widget _buildTimeLockInput() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
      Expanded(
      flex: 8,
      child: Container(
        //height: deviceSize.width/3,
        child: TextField(
            controller: _timeLockController,
            textAlign: TextAlign.right,
            decoration: new InputDecoration(
              labelText: "Time Lock",
              hintText: '0',
            ),
            onChanged: (value) {
              setState(() {
                timeLock = int.parse(value);
                if (value.isEmpty) timeLock = 0;
              });
            },
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ]),
      ),
    ),
        SizedBox(
          width: 7,
        ),
        Expanded(
            flex: 1,
            child: IconButton(
              onPressed: () {},
              icon: Icon(
                FontAwesomeIcons.calendarAlt,
              ),
              iconSize: 20,
              padding: EdgeInsets.all(3),
            )),
        Expanded(
          flex: 1,
          child: Tooltip(
              height: 75,
              textStyle: TextStyle(fontSize: 12, color: Colors.white),
              margin: EdgeInsets.only(left: 20, right: 20),
              preferBelow: false,
              message:
              'Time Lock is a unix `TimeStamp`.\nNeed to implement the calendar',
              child: IconButton(
                onPressed: () {},
                icon: Icon(
                  FontAwesomeIcons.questionCircle,
                  size: 15,
                ),
                iconSize: 10,
                padding: EdgeInsets.all(3),
              )),
        )
        //
      ],
    );
  }
  Widget _body(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      child: Column(
        children: [
          // _buildTimeLockInput(),
          Row(
            children: [
              AutoSizeText(
                'Fee Type',
                maxLines: 1,
                minFontSize: 9,
              ),

              Tooltip(
                  height: 100,
                  textStyle: TextStyle(fontSize: 12, color: Colors.white),
                  margin: EdgeInsets.only(left: 20, right: 20),
                  preferBelow: false,
                  message:
                  'By default, \'Weighted fee\' is selected.\n\nThe amount of the fee will be calculated, taking into account the weight of the transaction.\n\nTo set an absolute fee, you need to toggle \'Absolute fee\' in the advance options below.',
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(
                      FontAwesomeIcons.questionCircle,
                      size: 15,
                    ),
                    iconSize: 10,
                    padding: EdgeInsets.all(3),
                  )),
            ],
          ),
          Row(
            children: [],
          ),
          FeeTypeSelectorChip(),
          /*
          Row(
            children: [
              AutoSizeText(
                'Utxo Selection Strategy',
                maxLines: 1,
                minFontSize: 9,
              ),
              Tooltip(
                  height: 75,
                  textStyle: TextStyle(fontSize: 12, color: Colors.white),
                  margin: EdgeInsets.only(left: 20, right: 20),
                  preferBelow: false,
                  message: 'Strategy to sort our own unspent outputs pool',
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(
                      FontAwesomeIcons.questionCircle,
                      size: 15,
                    ),
                    iconSize: 10,
                    padding: EdgeInsets.all(3),
                  )),

           */
          //UtxoSelectionStrategyChip(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ExpansionPanel mainPanel = ExpansionPanel(
        headerBuilder: (context, isOpen) {
          return Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [Text('Advanced Settings')],
                )
              ],
            ),
          );
        },
        body: _body(context),
        isExpanded: _isOpenMain,
        canTapOnHeader: true);
    return ExpansionPanelList(
      children: [mainPanel],
      expansionCallback: (int index, bool isOpen) {
        setState(() {
          _isOpenMain = !isOpen;
        });
      },
      elevation: 0,
    );
  }
}
