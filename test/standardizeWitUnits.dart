import 'package:witnet_wallet/constants.dart';
import 'package:witnet_wallet/util/extensions/num_extensions.dart';
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
                          () =>
                              {expect(1.standardizeWitUnits(), '0.000000001')}),
                      test(
                          'to milliWit',
                          () => {
                                expect(
                                    1.standardizeWitUnits(
                                      outputUnit: WitUnit.milliWit,
                                      inputUnit: WitUnit.nanoWit,
                                    ),
                                    '0.000001')
                              }),
                      test(
                          'to microWit',
                          () => {
                                expect(
                                    1.standardizeWitUnits(
                                      outputUnit: WitUnit.microWit,
                                      inputUnit: WitUnit.nanoWit,
                                    ),
                                    '0.001')
                              }),
                      test(
                          'to nanoWit',
                          () => {
                                expect(
                                    1.standardizeWitUnits(
                                      outputUnit: WitUnit.nanoWit,
                                      inputUnit: WitUnit.nanoWit,
                                    ),
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
                                              1000.standardizeWitUnits(
                                                  outputUnit: WitUnit.Wit,
                                                  inputUnit: WitUnit.milliWit),
                                              '1')
                                        }),
                                test(
                                    'with decimal',
                                    () => {
                                          expect(
                                              0.0011.standardizeWitUnits(
                                                  outputUnit: WitUnit.Wit,
                                                  inputUnit: WitUnit.milliWit),
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
                                              1.standardizeWitUnits(
                                                  outputUnit: WitUnit.milliWit,
                                                  inputUnit: WitUnit.milliWit),
                                              '1')
                                        }),
                                test(
                                    'with decimal',
                                    () => {
                                          expect(
                                              1.001.standardizeWitUnits(
                                                  outputUnit: WitUnit.milliWit,
                                                  inputUnit: WitUnit.milliWit),
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
                                              10.standardizeWitUnits(
                                                  outputUnit: WitUnit.microWit,
                                                  inputUnit: WitUnit.milliWit),
                                              '10000')
                                        }),
                                test(
                                    'with decimal',
                                    () => {
                                          expect(
                                              0.0001.standardizeWitUnits(
                                                  outputUnit: WitUnit.microWit,
                                                  inputUnit: WitUnit.milliWit),
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
                                              0.000001.standardizeWitUnits(
                                                  outputUnit: WitUnit.nanoWit,
                                                  inputUnit: WitUnit.milliWit),
                                              '1')
                                        }),
                                test(
                                    'without decimal',
                                    () => {
                                          expect(
                                              1.standardizeWitUnits(
                                                  outputUnit: WitUnit.nanoWit,
                                                  inputUnit: WitUnit.milliWit),
                                              '1000000')
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
                                              1000000.standardizeWitUnits(
                                                  outputUnit: WitUnit.Wit,
                                                  inputUnit: WitUnit.microWit),
                                              '1')
                                        }),
                                test(
                                    'with decimal',
                                    () => {
                                          expect(
                                              11.standardizeWitUnits(
                                                  outputUnit: WitUnit.Wit,
                                                  inputUnit: WitUnit.microWit),
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
                                              1000.standardizeWitUnits(
                                                  outputUnit: WitUnit.milliWit,
                                                  inputUnit: WitUnit.microWit),
                                              '1')
                                        }),
                                test(
                                    'with decimal',
                                    () => {
                                          expect(
                                              1.001.standardizeWitUnits(
                                                  outputUnit: WitUnit.milliWit,
                                                  inputUnit: WitUnit.microWit),
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
                                              1.standardizeWitUnits(
                                                  outputUnit: WitUnit.microWit,
                                                  inputUnit: WitUnit.microWit),
                                              '1')
                                        }),
                                test(
                                    'with decimal',
                                    () => {
                                          expect(
                                              0.0001.standardizeWitUnits(
                                                  outputUnit: WitUnit.microWit,
                                                  inputUnit: WitUnit.microWit),
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
                                              0.001.standardizeWitUnits(
                                                  outputUnit: WitUnit.nanoWit,
                                                  inputUnit: WitUnit.microWit),
                                              '1')
                                        }),
                                test(
                                    'without decimal',
                                    () => {
                                          expect(
                                              10.standardizeWitUnits(
                                                  outputUnit: WitUnit.nanoWit,
                                                  inputUnit: WitUnit.microWit),
                                              '10000')
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
                                              1000000.standardizeWitUnits(
                                                  outputUnit: WitUnit.Wit,
                                                  inputUnit: WitUnit.Wit),
                                              '1000000')
                                        }),
                                test(
                                    'with decimal',
                                    () => {
                                          expect(
                                              0.000011.standardizeWitUnits(
                                                  outputUnit: WitUnit.Wit,
                                                  inputUnit: WitUnit.Wit),
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
                                              1.standardizeWitUnits(
                                                  outputUnit: WitUnit.milliWit,
                                                  inputUnit: WitUnit.Wit),
                                              '1000')
                                        }),
                                test(
                                    'with decimal',
                                    () => {
                                          expect(
                                              1.0001.standardizeWitUnits(
                                                  outputUnit: WitUnit.milliWit,
                                                  inputUnit: WitUnit.Wit),
                                              '1000.1')
                                        })
                              }),
                      group(
                          'to microWit',
                          () => {
                                test(
                                    'without decimal',
                                    () => {
                                          expect(
                                              1.standardizeWitUnits(
                                                  outputUnit: WitUnit.microWit,
                                                  inputUnit: WitUnit.Wit),
                                              '1000000')
                                        }),
                                test(
                                    'with decimal',
                                    () => {
                                          expect(
                                              0.0000001.standardizeWitUnits(
                                                  outputUnit: WitUnit.microWit,
                                                  inputUnit: WitUnit.Wit),
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
                                              0.0000000001.standardizeWitUnits(
                                                  outputUnit: WitUnit.nanoWit,
                                                  inputUnit: WitUnit.Wit),
                                              '0.1')
                                        }),
                                test(
                                    'without decimal',
                                    () => {
                                          expect(
                                              10.standardizeWitUnits(
                                                  outputUnit: WitUnit.nanoWit,
                                                  inputUnit: WitUnit.Wit),
                                              '10000000000')
                                        })
                              })
                    })
          });
}
