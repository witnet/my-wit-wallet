import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';

typedef void VoidCallback();

class ClosableView extends StatelessWidget {
  final VoidCallback closeSetting;
  final List<Widget> children;
  final String title;

  ClosableView(
      {Key? key,
      required this.closeSetting,
      required this.children,
      required this.title})
      : super(key: key);

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    return Padding(
        padding: EdgeInsets.zero,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  PaddedButton(
                      padding: EdgeInsets.zero,
                      label: 'Go back',
                      text: 'Go back',
                      type: ButtonType.iconButton,
                      color: theme.textTheme.titleLarge!.color,
                      iconSize: theme.textTheme.titleLarge!.fontSize! - 4,
                      icon: Icon(
                        FontAwesomeIcons.chevronLeft,
                        color: theme.textTheme.titleLarge!.color,
                        size: theme.textTheme.titleLarge!.fontSize! - 4,
                      ),
                      onPressed: this.closeSetting),
                  SizedBox(width: 8),
                  Container(
                      width: screenWidth > MAX_LAYOUT_WIDTH
                          ? null
                          : screenWidth * 0.65,
                      child: Text(
                        title,
                        style: theme.textTheme.titleLarge,
                      )),
                ],
              ),
              SizedBox(height: 16),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ...this.children,
                SizedBox(height: 16),
              ])
            ]));
  }
}
