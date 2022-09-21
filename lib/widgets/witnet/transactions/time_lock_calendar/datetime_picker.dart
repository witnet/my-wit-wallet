import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:witnet_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';

class DateTimePicker extends StatefulWidget {
  @override
  _DateTimePickerState createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
  late double _height;
  late double _width;
  late String _setTime, _setDate;
  late String _hour, _minute, _time;
  late String dateTime;

  DateTime selectedDate = DateTime.now();

  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);

  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime.now(),
        lastDate: DateTime(2101));
    if (picked != null)
      setState(() {
        selectedDate = picked;
        _dateController.text = DateFormat.yMd().format(selectedDate);
      });
  }

  Future<Null> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null)
      setState(() {
        selectedTime = picked;
        _hour = selectedTime.hour.toString();
        _minute = selectedTime.minute.toString();
        _time = _hour + ' : ' + _minute;
        _timeController.text = _time;
        _timeController.text = formatDate(
            DateTime(2019, 08, 1, selectedTime.hour, selectedTime.minute),
            [hh, ':', nn, " ", am]).toString();
      });
  }

  @override
  void initState() {
    _dateController.text = DateFormat.yMd().format(DateTime.now());

    _timeController.text = formatDate(
        DateTime(2019, 08, 1, DateTime.now().hour, DateTime.now().minute),
        [hh, ':', nn, " ", am]).toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    dateTime = DateFormat.yMd().format(DateTime.now());
    final deviceSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    double cardWidth;
    if (deviceSize.width > 400) {
      cardWidth = (400 * 0.7);
    } else
      cardWidth = deviceSize.width * 0.7;
    return Dialog(
        insetPadding: EdgeInsets.all(0),
        child: Container(
          width: cardWidth,
          height: deviceSize.height * 0.8,
          padding: EdgeInsets.all(7),
          child: Column(
            children: [
              Container(
                width: cardWidth,
                height: _height * 0.7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            _selectDate(context);
                          },
                          child: Container(
                            width: _width / 1.7,
                            height: _height / 9,
                            margin: EdgeInsets.only(top: 30),
                            alignment: Alignment.center,
                            child: TextFormField(
                              textAlign: TextAlign.center,
                              enabled: false,
                              keyboardType: TextInputType.text,
                              controller: _dateController,
                              onSaved: (String? val) {
                                if (val != null) _setDate = val;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            _selectTime(context);
                          },
                          child: Container(
                            margin: EdgeInsets.only(top: 30),
                            width: _width / 1.7,
                            height: _height / 9,
                            alignment: Alignment.center,
                            child: TextFormField(
                              textAlign: TextAlign.center,
                              onSaved: (String? val) {
                                if (val != null) _setTime = val;
                              },
                              enabled: false,
                              keyboardType: TextInputType.text,
                              controller: _timeController,
                              decoration: InputDecoration(
                                  disabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide.none),
                                  // labelText: 'Time',
                                  contentPadding: EdgeInsets.all(5)),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Cancel'),
                            )),
                            Expanded(
                                child: ElevatedButton(
                              onPressed: () {
                                BlocProvider.of<VTTCreateBloc>(context).add(
                                    SetTimelockEvent(
                                        dateTime: DateTime(
                                            selectedDate.year,
                                            selectedDate.month,
                                            selectedDate.day,
                                            selectedTime.hour,
                                            selectedTime.minute)));

                                Navigator.of(context).pop();
                              },
                              child: Text('Confirm'),
                            )),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
