import 'package:my_wit_wallet/util/storage/cache/read_through.dart';
import 'package:test/test.dart';

void main() {
  group('Storage implementation of read through cache pattern in memory', () {
    test('Should call fetch callback if it\'s first time getting the value',
        () async {
      int timesCalled = 0;
      String expectedValue = "Potato";
      bool saveCalled = false;

      ReadThrough<String> cache = ReadThrough((p0) async {
        timesCalled = timesCalled += 1;

        await Future.delayed(Duration(seconds: 0));

        return expectedValue;
      }, (p1) async {
        saveCalled = true;
        return true;
      }, (p0) async {
        return null;
      });

      expect(await cache.get("whatever"), expectedValue);
      expect(saveCalled, true);
      expect(timesCalled, 1);
    });

    test(
        'Should NOT call fetch callback if it\'s the second time getting the value',
        () async {
      int timesCalled = 0;
      String expectedValue = "Potato";
      bool saveCalled = false;

      ReadThrough<String> cache = ReadThrough((p0) async {
        timesCalled = timesCalled += 1;

        await Future.delayed(Duration(seconds: 0));

        return expectedValue;
      }, (p1) async {
        saveCalled = true;
        return true;
      }, (p0) async {
        if (timesCalled == 0) {
          return null;
        } else {
          return expectedValue;
        }
      });

      // call get multiple times
      expect(await cache.get(expectedValue), expectedValue);
      expect(await cache.get(expectedValue), expectedValue);
      expect(await cache.get(expectedValue), expectedValue);
      expect(await cache.get(expectedValue), expectedValue);
      expect(saveCalled, true);

      expect(timesCalled, 1);
    });
  });
}
