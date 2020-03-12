import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  var storage;

  StorageService() {
    storage = new FlutterSecureStorage();
  }

  Future<dynamic> read(key) async {
    var val = await storage.read(key: key);
    return val;
  }

  Future<void> delete(key) async {
    await storage.delete(key: key);
  }

  Future<void> save(key, value) async {
    await storage.write(key: key, value: value);
  }
}
