import 'package:witnet_wallet/util/extensions/string_extensions.dart';
import 'package:test/test.dart';

void main() {
  group(
      'String Extensions',
      () => {
            test(
                'fromPascalCaseToTitle',
                () => {
                      expect(
                          'PascalCase'.fromPascalCaseToTitle(), 'Pascal case')
                    })
          });
}
