import 'package:decimal/decimal.dart';
import 'package:my_wit_wallet/util/min_amount_unstake.dart';
import 'package:test/test.dart';

void main() async {
  test('staked is 0', () async {
    expect(getUnstakeMinAmount(0), Decimal.parse('0'));
  });
  test('staked is more than minimun staking amount (10_000)', () async {
    expect(getUnstakeMinAmount(20000), Decimal.parse('0.000000001'));
    expect(getUnstakeMinAmount(18000), Decimal.parse('18000'));
  });
  test('staked is less than minimun staking amount (10_000)', () async {
    // This case is unreachable, you can't have less than 10_000 WIT staked
    expect(getUnstakeMinAmount(9000), Decimal.parse('10000'));
  });
}
