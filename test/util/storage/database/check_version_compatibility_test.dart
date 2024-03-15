import 'package:my_wit_wallet/util/storage/database/check_version_compatibility.dart';
import 'package:test/test.dart';

void main() async {
  test('Check version compatibility', () async {
    expect(
        checkVersionCompatibility(
            apiVersion: '1.0.0', compatibleVersion: '1.0.0'),
        true);
    expect(
        checkVersionCompatibility(
            apiVersion: '1.0.1', compatibleVersion: '1.0.0'),
        true);
    expect(
        checkVersionCompatibility(
            apiVersion: '1.1.0', compatibleVersion: '1.0.0'),
        true);
    expect(
        checkVersionCompatibility(
            apiVersion: '2.0.0', compatibleVersion: '1.0.0'),
        false);
  });
}
