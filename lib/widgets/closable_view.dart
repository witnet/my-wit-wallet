import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wit_wallet/theme/colors.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';

typedef void VoidCallback();

class ClosableView extends StatelessWidget {
  final VoidCallback closeSetting;
  final List<Widget> children;

  ClosableView({Key? key, required this.closeSetting, required this.children})
      : super(key: key);

  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(right: 8, left: 8),
        child: Stack(children: [
          Positioned(
              top: 0,
              right: 0,
              child: PaddedButton(
                  padding: EdgeInsets.zero,
                  label: 'Go back to wallet settings',
                  text: 'Go back to wallet settings',
                  type: ButtonType.iconButton,
                  color: WitnetPallet.lightGrey,
                  iconSize: 24,
                  icon: Icon(
                    FontAwesomeIcons.solidCircleXmark,
                    size: 24,
                  ),
                  onPressed: this.closeSetting)),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(height: 24),
            ...this.children,
          ])
        ]));
  }
}
