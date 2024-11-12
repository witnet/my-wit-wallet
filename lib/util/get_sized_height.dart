import 'package:flutter/material.dart';

double getWalletListSize(BuildContext context, int walletsLenght) {
  double walletHeight = 98;
  double actionHeight = 40;
  return walletsLenght * walletHeight + actionHeight;
}

double getBottomNavigationPadding(BuildContext context) {
  return (MediaQuery.of(context).viewInsets.bottom +
      kBottomNavigationBarHeight +
      MediaQuery.of(context).viewPadding.bottom);
}
