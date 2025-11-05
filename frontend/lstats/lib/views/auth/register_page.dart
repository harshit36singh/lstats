import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lstats/viewmodels/auth_viewmodels.dart';
import 'package:lstats/views/auth/login_page.dart';
import 'package:lstats/views/auth/pages/home.dart';
import 'package:lstats/widgets/autocomplete.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController username = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController clgname = TextEditingController();

  @override
  void dispose() {
    username.dispose();
    email.dispose();
    password.dispose();
    clgname.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthViewModel>(context);
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            // Stripe 1: Header - Orange
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                color: const Color(0xFFFF6B3D),
                padding: EdgeInsets.symmetric(
                  vertical: height * 0.024,
                  horizontal: width * 0.08,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "Create Account",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: width * 0.10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -2,
                          height: 1,
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.01),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Join the coding community',
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.7),
                          fontSize: width * 0.03,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Stripe 2: Username Field - White
            Expanded(
              flex: 2,
              child: _buildInputStripe(
                width: width,
                height: height,
                color: Colors.white,
                icon: Icons.person_outline,
                label: "USERNAME",
                child: TextField(
                  controller: username,
                  keyboardType: TextInputType.name,
                  style: _fieldStyle(width),
                  decoration: _fieldDecoration("your_username", width),
                ),
              ),
            ),

            // Stripe 3: Email Field - Yellow
            Expanded(
              flex: 2,
              child: _buildInputStripe(
                width: width,
                height: height,
                color: const Color(0xFFFFB84D),
                icon: Icons.email_outlined,
                label: "EMAIL",
                child: TextField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  style: _fieldStyle(width),
                  decoration: _fieldDecoration("your.email@example.com", width),
                ),
              ),
            ),

            // Stripe 4: Password Field - Red
            Expanded(
              flex: 2,
              child: _buildInputStripe(
                width: width,
                height: height,
                color: const Color(0xFFE84855),
                icon: Icons.lock_outline,
                label: "PASSWORD",
                child: TextField(
                  controller: password,
                  obscureText: true,
                  style: _fieldStyle(width),
                  decoration: _fieldDecoration("••••••••", width),
                ),
              ),
            ),

            // Stripe 5: College Field - Pink
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                color: const Color(0xFFE94196),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: height * 0.008,
                      horizontal: width * 0.08,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.school_outlined, size: width * 0.04),
                              SizedBox(width: width * 0.015),
                              Text(
                                'COLLEGE',
                                style: TextStyle(
                                  fontSize: width * 0.028,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: height * 0.006),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 2),
                            color: Colors.white,
                          ),
                          child: AutoCompleteField(con: clgname),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Stripe 6: Register Button - Black
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: auth.isLoading
                    ? null
                    : () async {
                        try {
                          await http.get(
                            Uri.parse(
                              'https://lstats-backend.onrender.com/leaderboard/refresh',
                            ),
                          );

                          await auth.register(
                            username.text.trim(),
                            email.text.trim(),
                            password.text.trim(),
                            clgname.text,
                          );

                          if (auth.token != null && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Registration Successful!",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: width * 0.035,
                                  ),
                                ),
                                backgroundColor: const Color(0xFF6BCF7F),
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.all(width * 0.04),
                              ),
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    Homescreen(name: username.text),
                              ),
                            );
                          } else if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Something went wrong.",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: width * 0.035,
                                  ),
                                ),
                                backgroundColor: const Color(0xFFE84855),
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.all(width * 0.04),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Error: ${e.toString()}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: width * 0.035,
                                  ),
                                ),
                                backgroundColor: const Color(0xFFE84855),
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.all(width * 0.04),
                              ),
                            );
                          }
                        }
                      },
                child: Container(
                  width: double.infinity,
                  color: Colors.black,
                  child: Center(
                    child: auth.isLoading
                        ? SizedBox(
                            width: width * 0.08,
                            height: width * 0.08,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'CREATE ACCOUNT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: width * 0.045,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              SizedBox(width: width * 0.03),
                              Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: width * 0.07,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),

            // Stripe 7: Sign In Link - Gray
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                color: const Color(0xFFCCCCCC),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.04,
                          vertical: height * 0.008,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Already have an account? Sign In',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: width * 0.035,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: width * 0.015),
                          Icon(
                            Icons.arrow_outward,
                            color: Colors.black,
                            size: width * 0.04,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputStripe({
    required double width,
    required double height,
    required Color color,
    required IconData icon,
    required String label,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      color: color,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: height * 0.008,
            horizontal: width * 0.08,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: width * 0.04),
                    SizedBox(width: width * 0.015),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: width * 0.028,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: height * 0.006),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                  color: Colors.white,
                ),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint, double width) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: const Color(0xFFCCCCCC),
        fontWeight: FontWeight.w500,
        fontSize: width * 0.034,
      ),
      border: InputBorder.none,
      isDense: true,
      contentPadding: EdgeInsets.symmetric(
        horizontal: width * 0.04,
        vertical: width * 0.022,
      ),
    );
  }

  TextStyle _fieldStyle(double width) {
    return TextStyle(
      fontSize: width * 0.04,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    );
  }
}