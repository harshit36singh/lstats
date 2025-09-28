import 'package:flutter/material.dart';
import 'package:lstats/viewmodels/auth_viewmodels.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});

  final TextEditingController username = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthViewModel>(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Center(
              child: Text(
                "SignUp.",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
              ),
            ),
            SizedBox(height: 6),
            Center(
              child: Text(
                "Create your account",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w200),
              ),
            ),
            SizedBox(height: 20),

            Center(child: field("Username", Icon(Icons.person), false, username)),
            SizedBox(height: 15),
            Center(child: field("Email", Icon(Icons.email), false, email)),
            SizedBox(height: 15),
            Center(child: field("Password", Icon(Icons.password), true, password)),
            SizedBox(height: 9),
            
            auth.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      try {
                        await auth.register(username.text, email.text, password.text);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Registration successful!")),
                        );
                        Navigator.pop(context); // go back to login page
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      }
                    },
                    child: Text("Register"),
                  ),
          ],
        ),
      ),
    );
  }
}

// Reuse the same field widget
Widget field(String s, Icon? i, bool t, TextEditingController tc) {
  return Container(
    width: 300,
    child: TextField(
      controller: tc,
      obscureText: t,
      keyboardType: t ? TextInputType.text : TextInputType.emailAddress,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 1.5),
          borderRadius: BorderRadius.circular(20),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF6C63FF), width: 2.2),
          borderRadius: BorderRadius.circular(20),
        ),
        hintText: s,
        prefixIcon: i,
        contentPadding: i == null
            ? EdgeInsets.symmetric(vertical: 15, horizontal: 20)
            : null,
      ),
    ),
  );
}
