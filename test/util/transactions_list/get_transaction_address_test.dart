import 'package:flutter/widgets.dart';
import 'package:my_wit_wallet/util/transactions_list/get_transaction_address.dart';
import 'package:test/test.dart';
import 'package:witnet/explorer.dart';
import 'package:witnet/schema.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  String tolabel = 'to';
  String fromlabel = 'from';
  List<InputUtxo> inputs = [
    InputUtxo(
        address: 'wit1zl7ty0lwr7atp5fu34azkgewhtfx2fl4wv69cw',
        inputUtxo:
            '59e4dc54077871e71875a4b840da67c23659d89d41eaad85cdb9a5d552254b5d:9',
        value: 10180697116),
  ];
  List<InputUtxo> severalInputs = [
    InputUtxo(
        address: 'wit1zl7ty0lwr7atp5fu34azkgewhtfx2fl4wv69cw',
        inputUtxo:
            '59e4dc54077871e71875a4b840da67c23659d89d41eaad85cdb9a5d552254b5d:9',
        value: 10180697116),
    InputUtxo(
        address: 'wit2zl7ty0lwr7atp5fu34azkgewhtfx2fl4wv69cw',
        inputUtxo:
            '59e4dc54077871e71875a4b840da67c23659d89d41eaad85cdb9a5d552254b5d:9',
        value: 10180697116)
  ];
  List<ValueTransferOutput> outputs = [
    ValueTransferOutput(
        pkh: Address.fromAddress('wit1zl7ty0lwr7atp5fu34azkgewhtfx2fl4wv69cw')
            .publicKeyHash,
        timeLock: 000,
        value: 10180697115),
  ];

  String transactionAddressToLabel =
      getTransactionAddress(tolabel, inputs, outputs);
  String transactionAddressFromLabel =
      getTransactionAddress(fromlabel, inputs, outputs);
  String transactionAddressFromSeveralInputs =
      getTransactionAddress(fromlabel, severalInputs, outputs);

  group(
      'getTransactionAddress',
      () => {
            test(
                'with \'to\' label',
                () => {
                      expect(transactionAddressToLabel, 'wit1zl7...4wv69cw'),
                    }),
            test(
                'with \'from\' label',
                () => {
                      expect(transactionAddressFromLabel, 'wit1zl7...4wv69cw'),
                    }),
            test(
                'with \'from\' label and several inputs',
                () => {
                      expect(transactionAddressFromSeveralInputs,
                          'wit1zl7...4wv69cw'),
                    })
          });
}
