import 'package:flutter/material.dart';

class Layout extends StatelessWidget {
  final List<Widget> widgetList;
  final AppBar? appBar;

  const Layout({
    required this.widgetList,
    this.appBar,
  });


  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: appBar,
      resizeToAvoidBottomInset: false,
      backgroundColor: theme.backgroundColor,
      body: new GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: 100, maxWidth: 600),
                child: Column(children: widgetList),
              )
            )
          ],
        ),
      ),
    );
  }
}
