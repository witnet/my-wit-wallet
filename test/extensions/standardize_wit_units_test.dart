import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/util/extensions/num_extensions.dart';
import 'package:test/test.dart';

void main() {
  group(
      'standardizeWitUnits',
      () => {
            group(
                'nanoWit',
                () => {
                      test(
                          'to Wit',
                          () => {
                                expect(
                                    1
                                        .standardizeWitUnits()
                                        .formatWithCommaSeparator(),
                                    '0.000000001')
                              }),
                      test(
                          'to Wit with decimals',
                          () => {
                                expect(
                                    13999999872
                                        .standardizeWitUnits()
                                        .formatWithCommaSeparator(),
                                    '13.99')
                              }),
                      test(
                          'to milliWit',
                          () => {
                                expect(
                                    1
                                        .standardizeWitUnits(
                                          outputUnit: WitUnit.milliWit,
                                          inputUnit: WitUnit.nanoWit,
                                        )
                                        .formatWithCommaSeparator(),
                                    '0.000001')
                              }),
                      test(
                          'to microWit',
                          () => {
                                expect(
                                    1
                                        .standardizeWitUnits(
                                          outputUnit: WitUnit.microWit,
                                          inputUnit: WitUnit.nanoWit,
                                        )
                                        .formatWithCommaSeparator(),
                                    '0.001')
                              }),
                      test(
                          'to nanoWit',
                          () => {
                                expect(
                                    1
                                        .standardizeWitUnits(
                                          outputUnit: WitUnit.nanoWit,
                                          inputUnit: WitUnit.nanoWit,
                                        )
                                        .formatWithCommaSeparator(),
                                    '1')
                              })
                    }),
            group(
                'milliWit',
                () => {
                      group(
                          'to Wit',
                          () => {
                                test(
                                    'without decimal',
                                    () => {
                                          expect(
                                              1000
                                                  .standardizeWitUnits(
                                                      outputUnit: WitUnit.Wit,
                                                      inputUnit:
                                                          WitUnit.milliWit)
                                                  .formatWithCommaSeparator(),
                                              '1')
                                        }),
                                test(
                                    'with decimal',
                                    () => {
                                          expect(
                                              0.0011
                                                  .standardizeWitUnits(
                                                      outputUnit: WitUnit.Wit,
                                                      inputUnit:
                                                          WitUnit.milliWit)
                                                  .formatWithCommaSeparator(),
                                              '0.0000011')
                                        })
                              }),
                      group(
                          'to milliWit',
                          () => {
                                test(
                                    'without decimal',
                                    () => {
                                          expect(
                                              1
                                                  .standardizeWitUnits(
                                                      outputUnit:
                                                          WitUnit.milliWit,
                                                      inputUnit:
                                                          WitUnit.milliWit)
                                                  .formatWithCommaSeparator(),
                                              '1')
                                        }),
                                test(
                                    'with decimal',
                                    () => {
                                          expect(
                                              1.001
                                                  .standardizeWitUnits(
                                                      outputUnit:
                                                          WitUnit.milliWit,
                                                      inputUnit:
                                                          WitUnit.milliWit)
                                                  .formatWithCommaSeparator(),
                                              '1')
                                        })
                              }),
                      group(
                          'to microWit',
                          () => {
                                test(
                                    'without decimal',
                                    () => {
                                          expect(
                                              10
                                                  .standardizeWitUnits(
                                                      outputUnit:
                                                          WitUnit.microWit,
                                                      inputUnit:
                                                          WitUnit.milliWit)
                                                  .formatWithCommaSeparator(),
                                              '10,000')
                                        }),
                                test(
                                    'with decimal',
                                    () => {
                                          expect(
                                              0.0001
                                                  .standardizeWitUnits(
                                                      outputUnit:
                                                          WitUnit.microWit,
                                                      inputUnit:
                                                          WitUnit.milliWit)
                                                  .formatWithCommaSeparator(),
                                              '0.1')
                                        })
                              }),
                      group(
                          'to nanoWit',
                          () => {
                                test(
                                    'with decimal',
                                    () => {
                                          expect(
                                              0.000001
                                                  .standardizeWitUnits(
                                                      outputUnit:
                                                          WitUnit.nanoWit,
                                                      inputUnit:
                                                          WitUnit.milliWit)
                                                  .formatWithCommaSeparator(),
                                              '1')
                                        }),
                                test(
                                    'without decimal',
                                    () => {
                                          expect(
                                              1
                                                  .standardizeWitUnits(
                                                      outputUnit:
                                                          WitUnit.nanoWit,
                                                      inputUnit:
                                                          WitUnit.milliWit)
                                                  .formatWithCommaSeparator(),
                                              '1,000,000')
                                        })
                              })
                    }),
            group(
                'microWit',
                () => {
                      group(
                          'to Wit',
                          () => {
                                test(
                                    'without decimal',
                                    () => {
                                          expect(
                                              1000000
                                                  .standardizeWitUnits(
                                                      outputUnit: WitUnit.Wit,
                                                      inputUnit:
                                                          WitUnit.microWit)
                                                  .formatWithCommaSeparator(),
                                              '1')
                                        }),
                                test(
                                    'with decimal',
                                    () => {
                                          expect(
                                              11
                                                  .standardizeWitUnits(
                                                      outputUnit: WitUnit.Wit,
                                                      inputUnit:
                                                          WitUnit.microWit)
                                                  .formatWithCommaSeparator(),
                                              '0.000011')
                                        })
                              }),
                      group(
                          'to milliWit',
                          () => {
                                test(
                                    'without decimal',
                                    () => {
                                          expect(
                                              1000
                                                  .standardizeWitUnits(
                                                      outputUnit:
                                                          WitUnit.milliWit,
                                                      inputUnit:
                                                          WitUnit.microWit)
                                                  .formatWithCommaSeparator(),
                                              '1')
                                        }),
                                test(
                                    'with decimal',
                                    () => {
                                          expect(
                                              1.001
                                                  .standardizeWitUnits(
                                                      outputUnit:
                                                          WitUnit.milliWit,
                                                      inputUnit:
                                                          WitUnit.microWit)
                                                  .formatWithCommaSeparator(),
                                              '0.001001')
                                        })
                              }),
                      group(
                          'to microWit',
                          () => {
                                test(
                                    'without decimal',
                                    () => {
                                          expect(
                                              1
                                                  .standardizeWitUnits(
                                                      outputUnit:
                                                          WitUnit.microWit,
                                                      inputUnit:
                                                          WitUnit.microWit)
                                                  .formatWithCommaSeparator(),
                                              '1')
                                        }),
                                test(
                                    'with decimal',
                                    () => {
                                          expect(
                                              0.0001
                                                  .standardizeWitUnits(
                                                      outputUnit:
                                                          WitUnit.microWit,
                                                      inputUnit:
                                                          WitUnit.microWit)
                                                  .formatWithCommaSeparator(),
                                              '0.0001')
                                        })
                              }),
                      group(
                          'to nanoWit',
                          () => {
                                test(
                                    'with decimal',
                                    () => {
                                          expect(
                                              0.001
                                                  .standardizeWitUnits(
                                                      outputUnit:
                                                          WitUnit.nanoWit,
                                                      inputUnit:
                                                          WitUnit.microWit)
                                                  .formatWithCommaSeparator(),
                                              '1')
                                        }),
                                test(
                                    'without decimal',
                                    () => {
                                          expect(
                                              10
                                                  .standardizeWitUnits(
                                                      outputUnit:
                                                          WitUnit.nanoWit,
                                                      inputUnit:
                                                          WitUnit.microWit)
                                                  .formatWithCommaSeparator(),
                                              '10,000')
                                        })
                              })
                    }),
            group(
                'Wit',
                () => {
                      group(
                          'to Wit',
                          () => {
                                test(
                                    'without decimal',
                                    () => {
                                          expect(
                                              1000000
                                                  .standardizeWitUnits(
                                                      outputUnit: WitUnit.Wit,
                                                      inputUnit: WitUnit.Wit)
                                                  .formatWithCommaSeparator(),
                                              '1,000,000')
                                        }),
                                test(
                                    'with decimal',
                                    () => {
                                          expect(
                                              0.000011
                                                  .standardizeWitUnits(
                                                      outputUnit: WitUnit.Wit,
                                                      inputUnit: WitUnit.Wit)
                                                  .formatWithCommaSeparator(),
                                              '0.000011')
                                        })
                              }),
                      group(
                          'to milliWit',
                          () => {
                                test(
                                    'without decimal',
                                    () => {
                                          expect(
                                              1
                                                  .standardizeWitUnits(
                                                      outputUnit:
                                                          WitUnit.milliWit,
                                                      inputUnit: WitUnit.Wit)
                                                  .formatWithCommaSeparator(),
                                              '1,000')
                                        }),
                                test(
                                    'with decimal',
                                    () => {
                                          expect(
                                              1.0001
                                                  .standardizeWitUnits(
                                                      outputUnit:
                                                          WitUnit.milliWit,
                                                      inputUnit: WitUnit.Wit)
                                                  .formatWithCommaSeparator(),
                                              '1,000.1')
                                        })
                              }),
                      group(
                          'to microWit',
                          () => {
                                test(
                                    'without decimal',
                                    () => {
                                          expect(
                                              1
                                                  .standardizeWitUnits(
                                                      outputUnit:
                                                          WitUnit.microWit,
                                                      inputUnit: WitUnit.Wit)
                                                  .formatWithCommaSeparator(),
                                              '1,000,000')
                                        }),
                                test(
                                    'with decimal',
                                    () => {
                                          expect(
                                              0.0000001
                                                  .standardizeWitUnits(
                                                      outputUnit:
                                                          WitUnit.microWit,
                                                      inputUnit: WitUnit.Wit)
                                                  .formatWithCommaSeparator(),
                                              '0.1')
                                        })
                              }),
                      group(
                          'to nanoWit',
                          () => {
                                test(
                                    'with decimal',
                                    () => {
                                          expect(
                                              0.0000000001
                                                  .standardizeWitUnits(
                                                      outputUnit:
                                                          WitUnit.nanoWit,
                                                      inputUnit: WitUnit.Wit)
                                                  .formatWithCommaSeparator(),
                                              '0.1')
                                        }),
                                test(
                                    'without decimal',
                                    () => {
                                          expect(
                                              10
                                                  .standardizeWitUnits(
                                                      outputUnit:
                                                          WitUnit.nanoWit,
                                                      inputUnit: WitUnit.Wit)
                                                  .formatWithCommaSeparator(),
                                              '10,000,000,000')
                                        })
                              })
                    })
          });
}
