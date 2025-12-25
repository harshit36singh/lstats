import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  StompClient? _client;
  final FlutterLocalNotificationsPlugin local;

  NotificationService(this.local);

  void connect(String username) {
    if (_client != null && _client!.connected) return;

    _client = StompClient(
      config: StompConfig.sockJS(
        url: "https://lstats-railway-backend-production.up.railway.app/ws",
        stompConnectHeaders: {"username": username},
        webSocketConnectHeaders: {"username": username},
        onConnect: (frame) {
          print("🔥 NOTIFICATION WS CONNECTED");

          _client!.subscribe(
            destination: "/user/queue/notifications",
            callback: (frame) {
              final data = jsonDecode(frame.body!);

              _showLocalNotification(
                title: "LStats",
                body: data["message"] ?? "New notification",
              );
            },
          );
        },
        onWebSocketError: (e) => print("WS ERROR: $e"),
      ),
    );

    _client!.activate();
  }

  Future<void> _showLocalNotification(
      {required String title, required String body}) async {
    const android = AndroidNotificationDetails(
      "lstats_notifications",
      "LStats Notifications",
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: android);

    await local.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }
}

final notificationService =
    NotificationService(FlutterLocalNotificationsPlugin());
