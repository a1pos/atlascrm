import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class SimpleLogPrinter extends LogPrinter {
  @override
  List<String> log(LogEvent event) {
    debugPrint(event.message);
    return [event.message];
  }
}
