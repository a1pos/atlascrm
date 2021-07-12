import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

class CustomOutput extends LogOutput {
  final extension = ".txt";
  var currentDate = DateFormat("yyyy-MM-dd").format(DateTime.now()).toString();
  var currentTimeStamp;
  var path;
  var file;

  getCurrentTimeStamp() {
    currentTimeStamp = DateFormat("Hms").format(DateTime.now()).toString();

    return currentTimeStamp;
  }

  _write(String text) async {
    var timeStamp = getCurrentTimeStamp();
    final Directory directory = await getExternalStorageDirectory();
    final fileName = currentDate + extension;

    path = directory.path;

    final logs = Directory("logs");
    var logsExists = await logs.exists();

    if (!logsExists) {
      await new Directory(directory.path + '/' + 'Logs')
          .create(recursive: true)
          .then((Directory directory) {
        return null;
      });
    }

    final File file = File('${directory.path}/Logs/$fileName');

    file.writeAsString(
      timeStamp.toString() + " - " + text.trim() + "\n",
      mode: FileMode.writeOnlyAppend,
      encoding: utf8,
    );
  }

  void output(OutputEvent event) {
    for (var line in event.lines) {
      this._write(line);
    }
  }
}
