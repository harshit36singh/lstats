import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> showlocalnotification(String title, String icon) async {
  const AndroidNotificationDetails androidplatformchannelspecifics =
      AndroidNotificationDetails(
        'group_invites_channel', 
        'Group Invites', 
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      );
}
