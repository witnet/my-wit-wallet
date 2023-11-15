import 'package:logger/logger.dart';
import 'package:my_wit_wallet/util/storage/log_output.dart' as customLogOutput;

class DebugLogger {
  late Logger logger;
  static final DebugLogger _instance = DebugLogger._internal();

  DebugLogger._internal();

  factory DebugLogger() {
    _instance.logger = Logger(
      filter: DevelopmentFilter(),
      // Use the default LogFilter (-> only log in debug mode)
      printer: PrettyPrinter(
          methodCount: 2,
          // number of method calls to be displayed
          errorMethodCount: 8,
          // number of method calls if stacktrace is provided
          lineLength: 120,
          // width of the output
          colors: true,
          // Colorful log messages
          printEmojis: false,
          // Print an emoji for each log message
          printTime: true // Should each log print contain a timestamp
          ),
      // Use the PrettyPrinter to format and print log
      output: MultiOutput([customLogOutput.FileOutput(), ConsoleOutput()]),
    );
    return _instance;
  }

  void log(
    message,
  ) =>
      logger.d(message);
}
