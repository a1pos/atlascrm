import 'package:logger/logger.dart';

class SimpleLogPrinter extends LogPrinter {
  @override
  List<String> log(LogEvent event) {
    return [event.message];
  }
}
