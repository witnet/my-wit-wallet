import 'package:witnet/schema.dart';

extension ValueTransferOutputListExtension on List<ValueTransferOutput> {
  int valueNanoWit() {
    return this
        .map((ValueTransferOutput output) => output.value.toInt())
        .toList()
        .reduce((value, element) => value + element);
  }

  List<String> addressList() {
    return List<String>.generate(
        this.length, (index) => this[index].pkh.address);
  }

  bool containsAddress(String address) {
    return this.addressList().contains(address);
  }

  ValueTransferOutput byAddress(String address) {
    return this.firstWhere((output) => output.pkh.address == address);
  }

  void removeAddress(String address) {
    if (containsAddress(address)) {
      this.remove(this.firstWhere((output) => output.pkh.address == address));
    }
  }
}
