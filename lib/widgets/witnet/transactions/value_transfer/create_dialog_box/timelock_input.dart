import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TimeLockInput extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => TimeLockInputState();
}

class TimeLockInputState extends State<TimeLockInput> {
  late TextEditingController _timeLockController;
  int timeLock = 0;
  @override
  void initState() {
    _timeLockController = TextEditingController();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
}
