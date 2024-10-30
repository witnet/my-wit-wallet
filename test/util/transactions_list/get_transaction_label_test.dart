import 'package:flutter/material.dart';
import 'package:my_wit_wallet/util/storage/database/account.dart';
import 'package:my_wit_wallet/util/transactions_list/get_transaction_label.dart';
import 'package:test/test.dart';
import 'package:witnet/explorer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  List<String> externalAddresses = [
    'wit10v6vv58udnxtw92ckkkfw2csg74x5aqewan4ac',
    'wit136ksszlmep3np2chvd9pp5vwhhnk5d30fljw08',
    'wit156spszjytmv65c6mcmc6mr8jsffhq5304aelxj'
  ];
  List<String> internalAddresses = [
    'wit100w7q66ku6fpxp7j2szmvch6a2csrpdagv0rd7',
    'wit108h38kjszvf2m92phhqmxed6pv9990qvlgl5ax',
    'wit10awjad2dm2p7yeztgn0m8rw5vfwktvjtf4ycv3'
  ];
  Account singleAddressAccount = Account(
      walletName: 'walletName',
      address: 'wit1zl7ty0lwr7atp5fu34azkgewhtfx2fl4wv69cw',
      path: 'm');
  List<InputUtxo> inputs = [
    InputUtxo(
        address: 'wit1zl7ty0lwr7atp5fu34azkgewhtfx2fl4wv69cw',
        inputUtxo:
            '59e4dc54077871e71875a4b840da67c23659d89d41eaad85cdb9a5d552254b5d:9',
        value: 10180697116),
  ];

  String transactionFromLabel = getTransactionLabel(
      externalAddresses: externalAddresses,
      internalAddresses: internalAddresses,
      inputs: inputs,
      singleAddressAccount: null);

  String transactionToLabel = getTransactionLabel(
      externalAddresses: [],
      internalAddresses: [],
      inputs: inputs,
      singleAddressAccount: singleAddressAccount);

  group(
      'getTransactionAddress',
      () => {
            test(
                'with to label',
                () => {
                      expect(transactionToLabel, 'To'),
                    }),
            test(
                'with from label',
                () => {
                      expect(transactionFromLabel, 'From'),
                    }),
          });
}
