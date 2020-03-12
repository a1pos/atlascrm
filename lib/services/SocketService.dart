import 'dart:developer';

import 'package:atlascrm/config/ConfigSettings.dart';
import 'package:atlascrm/services/StorageService.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  final StorageService storageService = new StorageService();

  static IO.Socket SOCKET;

  Future<dynamic> getToken() async {
    return await storageService.read("token");
  }

  IO.Socket getInstance() {
    return SOCKET;
  }

  Future<void> initWebSocketConnection() async {
    try {
      var token = await storageService.read("token");

      IO.Socket socket = IO.io(ConfigSettings.WS_URL, <String, dynamic>{
        'transports': ['websocket'],
        'extraHeaders': {'Authorization': 'Google $token'}
      });

      socket.on('connect', (_) {
        print('connect');
        SOCKET = socket;
      });

      socket.on('disconnect', (_) {
        print('disconnect');
        SOCKET = null;
      });
    } catch (err) {
      log(err);
    }
  }
}
