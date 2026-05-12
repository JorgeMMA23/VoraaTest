import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationService {
  final FirebaseMessaging _messaging;
  final StreamController<RemoteMessage> _messageController =
      StreamController<RemoteMessage>.broadcast();
  String? token;

  PushNotificationService(this._messaging);

  Stream<RemoteMessage> get messages => _messageController.stream;

  Future<String?> init() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    token = await _messaging.getToken();

    FirebaseMessaging.onMessage.listen(_messageController.add);
    FirebaseMessaging.onMessageOpenedApp.listen(_messageController.add);

    return token;
  }

  void dispose() {
    _messageController.close();
  }
}
