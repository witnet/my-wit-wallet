import 'dart:io';

import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:my_wit_wallet/globals.dart' as globals;

class FileManager {
  static FileManager? _instance;
  FileManager._internal() {
    _instance = this;
  }

  factory FileManager() => _instance ?? FileManager._internal();

  Future<String?> get _directoryPath async {
    Directory directory;

    if (!Platform.isIOS) {
      directory = Directory('/storage/emulated/0/Download');
      if (!(await directory.exists()))
        directory = await getDownloadsDirectory() ??
            await getApplicationDocumentsDirectory();
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    return directory.path;
  }

  Future<void> writeAndOpenJsonFile(String bytes, String name) async {
    globals.biometricsAuthInProgress = true;
    if (Platform.isAndroid || Platform.isIOS) {
      bool hasPermission = await _requestWritePermission();
      if (!hasPermission) return;
    }

    final path = await _directoryPath;
    // Create a file for the path of
    // device and file name with extension
    File file = File('$path/$name');
    print("Save file");

    // Write the data in the file you have created
    file.writeAsString(bytes);

    // opens the file
    OpenFile.open('$path', type: 'application/json');
    OpenFile.open('$path/$name', type: 'application/json');
  }

  // requests storage permission
  Future<bool> _requestWritePermission() async {
    await Permission.storage.request();
    return await Permission.storage.request().isGranted;
  }
}
