import 'package:flutter/material.dart';
import 'package:witnet_wallet/widgets/headerLayout.dart';

class Layout extends StatelessWidget {
  final List<Widget> widgetList;
  final AppBar? appBar;
  final List<Widget> actions;
  final double actionsSize;

  const Layout({
    required this.widgetList,
    required this.actions,
    required this.actionsSize,
    this.appBar,
  });

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    GlobalKey contentKey = GlobalKey();
    return Scaffold(
      appBar: appBar,
      resizeToAvoidBottomInset: false,
      backgroundColor: theme.backgroundColor,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: ListView(
          children: [
            HeaderLayout(),
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: 100,
                  maxWidth: 600,
                ),
                child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(children: widgetList)),
              ),
            ),
            SizedBox(
              height: actionsSize,
            )
          ],
        ),
      ),
      floatingActionButton: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: 100, maxWidth: 600),
          child: Padding(
            padding: EdgeInsets.only(left: 32),
            child: Column(
              key: contentKey,
              mainAxisAlignment: MainAxisAlignment.end,
              children: actions,
            ),
          ),
        ),
      ),
    );
  }
}
