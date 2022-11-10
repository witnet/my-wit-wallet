import 'package:flutter_test/flutter_test.dart';
import 'package:witnet_wallet/main.dart' as app;

void main() async {
  testWidgets("Wallet Test", (WidgetTester tester) async {
    app.main();

    await tester.pumpAndSettle();
  });
}
