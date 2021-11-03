import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/avd.dart';
import 'package:flutter_svg/flutter_svg.dart';

const Map<String, String> _assetNames = {
  'explorer': 'assets/img/block-explorer.svg',
  'favicon': 'assets/img/favicon.svg',
  'wit': 'assets/img/wit.svg',
  'witnet_dark': 'assets/img/witnet_dark.svg',
};

class SVGWidget extends StatefulWidget {
  const SVGWidget({
    Key? key,
    required this.title,
    required this.size,
    required this.img,
  }) : super(key: key);
  final String title;
  final String img;
  final double size;
  @override
  _SVGWidgetState createState() => _SVGWidgetState();
}

class _SVGWidgetState extends State<SVGWidget> {
  final List<Widget> _painters = <Widget>[];
  late double _dimension;

  @override
  void initState() {
    super.initState();
    _dimension = widget.size;

    _painters.add(
      SvgPicture.asset(_assetNames[widget.img]!),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_dimension > MediaQuery.of(context).size.width - 10.0) {
      _dimension = MediaQuery.of(context).size.width - 10.0;
    }
    return SizedBox(
      width: _dimension,
      height: _dimension,
      child: SvgPicture.asset(_assetNames[widget.img]!),
    );
  }
}
