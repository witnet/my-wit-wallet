// MaterialPageRoute without transition
import 'package:flutter/material.dart';

class CustomPageRoute extends MaterialPageRoute {
  CustomPageRoute({builder, maintainState, settings})
      : super(
            builder: builder, maintainState: maintainState, settings: settings);

  @override
  Duration get transitionDuration => const Duration(milliseconds: 0);
}
