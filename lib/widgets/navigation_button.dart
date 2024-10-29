import 'package:flutter/material.dart';
import 'package:my_wit_wallet/util/get_navigation_color.dart';

typedef void VoidCallback();

class NavigationButton extends StatelessWidget {
  NavigationButton({
    required this.button,
    required this.routesList,
  });
  final Widget button;
  final List<String> routesList;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        button,
        Positioned(
            bottom: 0,
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: getNavigationPointerColor(
                    context: context, routesList: routesList),
                shape: BoxShape.circle,
              ),
            ))
      ],
    );
  }
}
