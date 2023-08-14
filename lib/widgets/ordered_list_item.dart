import 'package:flutter/material.dart';

Widget buildOrderedListItem(String number, String text, BuildContext context) {
  final theme = Theme.of(context);
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(number,
          style: theme.textTheme.bodyLarge!.copyWith(
            fontWeight: FontWeight.bold,
          )),
      Expanded(
        child: Text(text, style: theme.textTheme.bodyLarge),
      ),
    ],
  );
}
