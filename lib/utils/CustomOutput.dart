import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';

class CustomOutput extends LogOutput {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  final extension = ".txt";
  var currentDate = DateFormat("yyyyMMdd").format(DateTime.now()).toString();
  var currentTimeStamp;
  var path;
  var file;

  getCurrentTimeStamp() {
    currentTimeStamp = DateFormat("Hms").format(DateTime.now()).toString();

    return currentTimeStamp;
  }

  Future<void> initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();

    _packageInfo = info;
  }

  _write(String text) async {
    initPackageInfo();
    final Directory directory = await getExternalStorageDirectory();

    final fileName = "Round2CRM" +
        "v" +
        _packageInfo.version +
        "-" +
        currentDate +
        extension;

    final logs = Directory("logs");
    var logsExists = await logs.exists();
    var timeStamp = getCurrentTimeStamp();

    if (!logsExists) {
      await new Directory(directory.path + '/' + 'Logs')
          .create(recursive: true)
          .then((Directory directory) {
        return null;
      });
    }

    final File file = File('${directory.path}/Logs/$fileName');

    file.writeAsString(
      "\n $timeStamp - " + text.trim(),
      mode: FileMode.append,
      encoding: utf8,
    );
  }

  void output(OutputEvent event) {
    for (var line in event.lines) {
      this._write(line);
    }
  }
}
