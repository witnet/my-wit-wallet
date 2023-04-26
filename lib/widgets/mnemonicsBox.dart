import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:my_wit_wallet/bloc/crypto/api_crypto.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/widgets/dashed_rect.dart';

String _language = 'English';
int _radioWordCount = 12;

Future<String> _genMnemonic() async {
  return await Locator.instance
      .get<ApiCrypto>()
      .generateMnemonic(_radioWordCount, _language);
}

class MnemonicBox extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final future = useMemoized(() {
      _genMnemonic();
    });
    return FutureBuilder<Widget>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final mnemonic = snapshot.data as String;
            return DashedRect(
              color: Colors.grey,
              strokeWidth: 1.0,
              gap: 3.0,
              text: mnemonic,
            );
          }
          return Center(
            child: SpinKitCircle(
              color: theme.primaryColor,
            ),
          );
        });
  }
}
