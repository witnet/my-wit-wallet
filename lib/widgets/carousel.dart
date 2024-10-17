import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:my_wit_wallet/theme/colors.dart';

class Carousel extends StatefulWidget {
  final List<String> list;

  Carousel({Key? key, required this.list}) : super(key: key);

  @override
  _CarouselState createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  int page = 0;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      CarouselSlider.builder(
        itemCount: widget.list.length,
        itemBuilder: (context, itemIndex, index) {
          return buildView(context, widget.list[itemIndex]);
        },
        options: CarouselOptions(
            height: 100,
            enlargeCenterPage: true,
            onPageChanged: (val, _) {
              setState(() {
                page = val;
              });
            }),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _buildDotsList(),
      ),
    ]);
  }

  List<Widget> _buildDotsList() {
    List<Widget> childs = [];
    for (int i = 0; i < widget.list.length; i++) {
      childs.add(_buildDotIndicator(context, widget.list[i], i));
    }
    return childs;
  }

  //Widget
  Widget _buildDotIndicator(
      BuildContext context, String element, dynamic index) {
    return Container(
      margin: EdgeInsets.all(4),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: index == page ? WitnetPallet.brightCyan : WitnetPallet.lightGrey,
      ),
    );
  }

  //Widget
  Widget buildView(BuildContext context, item) {
    final theme = Theme.of(context);
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(left: 24, right: 24, top: 0, bottom: 8),
      child: Text(
        item,
        style: theme.textTheme.bodyLarge,
        textAlign: TextAlign.center,
      ),
    );
  }
}
