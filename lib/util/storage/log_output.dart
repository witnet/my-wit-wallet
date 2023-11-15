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
    _sink = (await getDirectoryForLogRecord()).openWrite(
      mode: overrideExisting ? FileMode.writeOnly : FileMode.writeOnlyAppend,
      encoding: encoding,
    );
  }

  Future<File> getDirectoryForLogRecord() async {
    final String? logsPath =
        await interface.createFolderInDocuments('myWitWallet');
    return File('$logsPath/myWitWalletLogs.txt');
  }

  @override
  void output(OutputEvent event) {
    _sink?.writeAll(event.lines, '\n');
  }

  @override
  Future<void> destroy() async {
    await _sink?.flush();
    await _sink?.close();
  }
}
