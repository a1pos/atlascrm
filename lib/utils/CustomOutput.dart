import 'dart:io';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

class CustomOutput extends LogOutput {
  @override
  Future<String> get _localPath async {
    Directory directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/woahnellllly.txt');
  }

  Future<File> writeToFile(String line) async {
    final file = await _localFile;

    return file.writeAsString('$line');
  }

  void output(OutputEvent event) {
    for (var line in event.lines) {
      this.writeToFile(line);
    }
  }
}
