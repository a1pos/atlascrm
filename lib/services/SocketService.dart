import 'dart:developer';

import 'package:atlascrm/config/ConfigSettings.dart';
import 'package:atlascrm/services/StorageService.dart';
import 'package:flutter_pusher/pusher.dart';

class SocketService {
  final StorageService storageService = new StorageService();

  Future<void> initWebSocketConnection() async {
    try {
      await Pusher.init(
          ConfigSettings.PUSHER_KEY,
          PusherOptions(
            cluster: "us2",
          ),
          enableLogging: true);

      Pusher.connect(onConnectionStateChange: (x) async {
        print("connected");
      }, onError: (x) {
        print("Error: ${x.message}");
      });
    } catch (err) {
      log(err);
    }
  }
}
