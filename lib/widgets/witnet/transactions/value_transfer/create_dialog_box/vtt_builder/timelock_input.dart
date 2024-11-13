import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/widgets/buttons/custom_btn.dart';
import 'package:my_wit_wallet/widgets/buttons/icon_btn.dart';

typedef void VoidCallback();

class TimelockInput extends StatelessWidget {
  final VoidCallback onClearTimelock;
  final VoidCallback onSelectedDate;
  final bool timelockSet;
  final DateTime? calendarValue;
  const TimelockInput({
    Key? key,
    required this.timelockSet,
    required this.onSelectedDate,
    required this.onClearTimelock,
    required this.calendarValue,
  }) : super(key: key);

  String _formatTimeLock() =>
      DateFormat('h:mm a E, MMM dd yyyy ').format(calendarValue!);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    ExtendedTheme extendedTheme = theme.extension<ExtendedTheme>()!;
    return Column(
      children: [
        SizedBox(height: 15),
        Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(localization.timelock, style: theme.textTheme.labelLarge),
              SizedBox(width: 8),
              Tooltip(
                  height: 60,
                  message: localization.timelockTooltip,
                  child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Icon(FontAwesomeIcons.circleQuestion,
                          size: 12, color: extendedTheme.inputIconColor)))
            ]),
        SizedBox(
          height: 8,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
                flex: timelockSet ? 8 : 9,
                child: CustomButton(
                  padding: EdgeInsets.zero,
                  text:
                      '${timelockSet ? _formatTimeLock() : localization.setTimelock}',
                  onPressed: onSelectedDate,
                  attachedIcon: true,
                  icon: Icon(FontAwesomeIcons.calendar, size: 12),
                  type: CustomBtnType.secondary,
                )),
            timelockSet
                ? Flexible(
                    flex: 1,
                    child: IconBtn(
                      padding: EdgeInsets.zero,
                      label: localization.clearTimelockLabel,
                      text: localization.clearTimelockLabel,
                      iconBtnType: IconBtnType.icon,
                      color: theme.inputDecorationTheme.errorStyle?.color,
                      iconSize: 12,
                      icon: Icon(
                        FontAwesomeIcons.trashCan,
                        size: 12,
                      ),
                      onPressed: () =>
                          timelockSet ? onClearTimelock() : onSelectedDate(),
                    ))
                : Flexible(flex: 0, child: Container()),
          ],
        ),
      ],
    );
  }
}
