import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lstats/services/api_service.dart'; // Your Auth storage service

class SettingsPage extends StatefulWidget {
  final int userId; // Pass current user ID

  const SettingsPage({super.key, required this.userId});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isLoggingOut = false;

  Future<void> logout() async {
    setState(() => isLoggingOut = true);
    await AuthStorage.logout(); // Clear user session
    setState(() => isLoggingOut = false);
    Navigator.of(context).pushReplacementNamed('/login'); // Navigate to login
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFD700),
        foregroundColor: Colors.black,
        title: const Text(
          'SETTINGS',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        elevation: 3,
        shape: const Border(
          bottom: BorderSide(color: Colors.black, width: 3),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildUserIdCard(),
            const SizedBox(height: 24),
            _buildLogoutButton(isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildUserIdCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Colors.yellow, width: 4),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700),
              border: Border.all(color: Colors.black, width: 3),
            ),
            child: const Icon(Icons.person, size: 32, color: Colors.black),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'USER ID',
                  style: TextStyle(
                    color: Colors.yellow,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.userId}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    shadows: [
                      Shadow(color: Colors.black, offset: Offset(3, 3)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(bool isMobile) {
    return GestureDetector(
      onTap: isLoggingOut ? null : logout,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isMobile ? 16 : 20,
        ),
        decoration: BoxDecoration(
          color: isLoggingOut ? Colors.grey : const Color(0xFFFF3366),
          border: Border.all(color: Colors.black, width: 4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              isLoggingOut ? 'LOGGING OUT...' : 'LOGOUT',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
