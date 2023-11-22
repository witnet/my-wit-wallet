import 'package:logger/logger.dart';
import 'package:my_wit_wallet/util/storage/path_provider_interface.dart';
import 'dart:convert';
import 'dart:io';

/// Writes the log output to a file.
class FileOutput extends LogOutput {
  final bool overrideExisting;
  final Encoding encoding;
  PathProviderInterface interface = PathProviderInterface();
  IOSink? _sink;

  FileOutput({
    this.overrideExisting = false,
    this.encoding = utf8,
  });

  @override
  Future<void> init() async {
    await Future.delayed(Duration(seconds: 5));
    await setSink();
  }

  Future<File> getDirectoryForLogRecord() async {
    final String? logsPath =
        await interface.createFolderInDocuments('myWitWalletLogs');
    return File('$logsPath/myWitWalletLogs.txt');
  }

  Future<void> setSink() async {
    File file = await getDirectoryForLogRecord();
    if (_sink == null) {
      _sink = file.openWrite(
        mode: overrideExisting ? FileMode.writeOnly : FileMode.writeOnlyAppend,
        encoding: encoding,
      );
    }
  }

  @override
  void output(OutputEvent event) async {
    if (_sink == null) {
      await setSink();
    }
    _sink?.writeAll(event.lines, '\n');
  }

  @override
  Future<void> destroy() async {
    await _sink?.flush();
    await _sink?.close();
  }
}
