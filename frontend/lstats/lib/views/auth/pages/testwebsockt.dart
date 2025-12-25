import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:lstats/main.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class WebSocketTestPage extends StatefulWidget {
  const WebSocketTestPage({super.key});

  @override
  State<WebSocketTestPage> createState() => _WebSocketTestPageState();
}

class _WebSocketTestPageState extends State<WebSocketTestPage> {
  StompClient? stompClient;
  final username = "umang_agrahari";

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  void _connectWebSocket() {
    stompClient = StompClient(
      config: StompConfig.sockJS(
        url: "https://lstats-railway-backend-production.up.railway.app/ws",
        stompConnectHeaders: {"username": username},
        webSocketConnectHeaders: {"username": username},
        onConnect: _onConnected,
        onWebSocketError: (error) => print("❌ WS ERROR: $error"),
        reconnectDelay: Duration(milliseconds: 1500),
      ),
    );

    stompClient!.activate();
  }

  void _onConnected(StompFrame frame) {
    print("🟢 CONNECTED!");

    stompClient!.subscribe(
      destination: "/user/queue/notifications",
      callback: (frame) {
        print("📩 GOT MESSAGE: ${frame.body}");
        _showLocalNotification(frame.body ?? "No message");

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Notification: ${frame.body}")));
      },
    );

    print("🎯 Subscribed to /user/queue/notifications");
  }

  @override
  void dispose() {
    stompClient?.deactivate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("WebSocket Test")),
      body: Center(
        child: ElevatedButton(
          child: const Text("Trigger Test Notification"),
          onPressed: () async {
            final url = Uri.parse(
              "https://lstats-railway-backend-production.up.railway.app/notification/test?username=$username",
            );

            print("📤 Triggering test notification...");
            try {
              await http.post(url);
            } catch (e) {
              print("❌ Error calling backend: $e");
            }
          },
        ),
      ),
    );
  }
}

Future<void> _showLocalNotification(String message) async {
  const android = AndroidNotificationDetails(
    'lstats_notifications',
    'LStats Notifications',
    importance: Importance.max,
    priority: Priority.high,
  );

  const details = NotificationDetails(android: android);

  await flutterlocalnotification.show(
    DateTime.now().millisecondsSinceEpoch ~/ 1000,
    "LStats",
    message,
    details,
  );
}
