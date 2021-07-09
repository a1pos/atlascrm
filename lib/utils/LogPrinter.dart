import 'package:logger/logger.dart';

class SimpleLogPrinter extends LogPrinter {
  @override
  List<String> log(LogEvent event) {
    print(event.message);
    return [event.message];
  }
}
