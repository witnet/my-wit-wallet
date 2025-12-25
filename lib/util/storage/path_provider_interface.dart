import 'dart:convert';
import 'dart:io' as io;
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/globals.dart' as globals;
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

import 'package:open_file/open_file.dart';

enum Platforms { Linux, Macos, Windows, IOS, Android }

class PathProviderInterface {
  static final PathProviderInterface _interface =
      PathProviderInterface._internal();

  factory PathProviderInterface() {
    if (!_interface.initialized) {}
    return _interface;
  }

  PathProviderInterface._internal();

  PathProviderPlatform platform = PathProviderPlatform.instance;

  late String applicationSupportPath;
  late String applicationDocumentsPath;

  //String downloadsPath;
  //String libraryPath;
  late List<String> externalCachePaths;
  late List<String> externalStoragePaths;

  //String temporaryPath;
  bool initialized = false;

  Future<void> init() async {
    applicationSupportPath = await localPath;
    initialized = true;
  }

  Future<String> get localPath async {
    return (await getApplicationSupportDirectory()).path;
  }

  Future<io.File> localFile(
      {required String name, required String extension}) async {
    final path = await localPath;
    return io.File('$path${io.Platform.pathSeparator}$name.$extension');
  }

  Future<Map<String, dynamic>> readJsonFile(String name) async {
    io.File file = await localFile(name: name, extension: 'json');
    final contents = await file.readAsString();
    return jsonDecode(contents);
  }

  Future<Map<String, String>> readWalletListFile() async {
    io.File file = await localFile(name: 'wallets', extension: 'json');
    final contents = await file.readAsString();
    var data = jsonDecode(contents);
    return data;
  }

  String getFilePath(String name, String extension) {
    return '$applicationSupportPath${io.Platform.pathSeparator}$name.$extension';
  }

  String getWalletPath(String name) {
    return getFilePath(name, 'wit');
  }

  String getDbWalletsPath() {
    if (USE_MOCK_WALLETS_FILE){
      return getFilePath('mock-wallets', 'wit');
    }
    return getFilePath(
        globals.testingActive ? 'test-wallets' : 'wallets', 'wit');
  }

  Future<bool> fileExists(String filename) async =>
      await io.File(filename).exists();

  Future<bool> walletsExist() async {
    List<String> files = await getWalletFiles();
    return files.isNotEmpty;
  }

  void saveFile(String name, String extension, String contents) {
    io.File file = io.File(getFilePath(name, extension));
    file.writeAsString(contents);
  }

  Future<bool> deleteWalletFile() async {
    io.File file = io.File(getDbWalletsPath());
    await file.delete();
    return true;
  }

  Future<String> readFile(String filePath) async {
    io.File file = io.File(filePath);
    String content = await file.readAsString();
    return content;
  }

  Future<List<String>> getWalletFiles() async {
    List<String> files = [];
    await init();
    await io.Directory("${_interface.applicationSupportPath}")
        .list()
        .forEach((element) {
      if (element.path.endsWith('.wit')) {
        files.add(
            element.path.split(io.Platform.pathSeparator).last.split('.')[0]);
      }
    });
    return files;
  }

  Future<String?> get directoryPath async {
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

  Future<String?> get logsDirectoryPath async {
    Directory directory;
    if (Platform.isAndroid) {
      directory = Directory('/storage/emulated/0/Download');
      if (!(await directory.exists()))
        directory = await getDownloadsDirectory() ??
            await getApplicationDocumentsDirectory();
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    return directory.path;
  }

  Future<String> createFolderInDocuments(String folderName) async {
    final String? _logsDirectory = await logsDirectoryPath;
    final Directory _documentsFolder =
        Directory('$_logsDirectory/$folderName/');

    if (await _documentsFolder.exists()) {
      return _documentsFolder.path;
    } else {
      final Directory _appDocumentsNewFolder =
          await _documentsFolder.create(recursive: true);
      return _appDocumentsNewFolder.path;
    }
  }

  Future<void> writeAndOpenJsonFile(String bytes, String name) async {
    globals.biometricsAuthInProgress = true;
    await writeJsonFile(bytes, name);

    await openSavedFile(name);
  }

  Future<void> writeJsonFile(String bytes, String name) async {
    String? path = await directoryPath;
    // Create a file for the path of
    // device and file name with extension
    File file = File('$path/$name');

    // Write the data in the file you have created
    file.writeAsString(bytes);
    print("Saved file path: $path/$name");
  }

  Future<PermissionStatus> requestExternalStoragePermission() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final status = await Permission.storage.status;
      if (status.isDenied) {
        await Permission.storage.request();
      }
      return status;
    } else {
      return PermissionStatus.granted;
    }
  }

  Future<void> openSavedFile(String fileName) async {
    String? path = await directoryPath;

    if (Platform.isIOS || Platform.isMacOS) {
      try {
        // opens the file
        await OpenFile.open('$path/$fileName', type: 'application/json');
      } catch (err) {
        print('Error opening json file: $err');
        // opens the directory
        await OpenFile.open('$path');
      }
    } else if (Platform.isAndroid) {
      final status = await requestExternalStoragePermission();
      if (status.isGranted || status.isProvisional) {
        // opens the directory
        await OpenFile.open('$path');
      }
    }
    await OpenFile.open('$path');
  }
}
