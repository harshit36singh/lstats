import 'package:flutter/material.dart';

class PresenceNotifier extends ChangeNotifier {
  final Set<String> _onlineUsers = {};

  void updateonlineusers(List<String> users) {
    print("🔄 PresenceNotifier updating with: $users");
    _onlineUsers.clear();
    _onlineUsers.addAll(users);
    print("📊 Current online users: $_onlineUsers");
    notifyListeners();
  }

  bool isonline(String username) {
    final result = _onlineUsers.contains(username);
    print("❓ Checking if $username is online: $result");
    return result;
  }

  Set<String> get onlineUsers => Set.from(_onlineUsers);
}

final presenceNotifier = PresenceNotifier();