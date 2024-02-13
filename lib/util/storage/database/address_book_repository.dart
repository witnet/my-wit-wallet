import 'package:sembast/sembast.dart';

class AddressBookEntry {
  String name;
  String address;

  AddressBookEntry(this.name, this.address);

  factory AddressBookEntry.fromJson(Map<String, dynamic> data) {
    return AddressBookEntry(data['name'], data['address']);
  }

  Map<String, dynamic> jsonMap() {
    return {
      "name": this.name,
      "address": this.address,
    };
  }
}

class AddressBookRepository {
  final StoreRef _store = stringMapStoreFactory.store("address_book");

  Future<bool> insertAddressBookEntry(
    AddressBookEntry addressBookEntry,
    DatabaseClient databaseClient,
  ) async {
    return true;
  }

  Future<bool> updateAddressBookEntry(
      AddressBookEntry addressBookEntry, DatabaseClient databaseClient) async {
    return true;
  }

  Future<bool> deleteAddressBookEntry(
    AddressBookEntry addressBookEntry,
    DatabaseClient databaseClient,
  ) async {
    return true;
  }

  Future<AddressBookEntry?> getAddressBookEntry(
      String address, DatabaseClient databaseClient) async {
    try {
      dynamic addressBookEntryJson =
          await _store.record(address).get(databaseClient);
      AddressBookEntry addressBookEntry =
          AddressBookEntry.fromJson(addressBookEntryJson);
      return addressBookEntry;
    } catch (e) {
      return null;
    }
  }

  Future<List<AddressBookEntry>> getEntries(
      DatabaseClient databaseClient) async {
    final List<RecordSnapshot<dynamic, dynamic>> snapshots =
        await _store.find(databaseClient);
    List<AddressBookEntry> accounts = snapshots
        .map((snapshot) => AddressBookEntry.fromJson(snapshot.value))
        .toList(growable: false);
    return accounts;
  }
}
