import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lstats/viewmodels/auth_viewmodels.dart';
import 'package:lstats/views/auth/login_page.dart';
import 'package:lstats/views/auth/pages/home.dart';
import 'package:lstats/widgets/autocomplete.dart';
import 'package:provider/provider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

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
    Color c = Colors.white;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = constraints.maxHeight;
            final screenWidth = constraints.maxWidth;

            return Column(
              children: [
                // Stripe 1: Header - Orange
                Expanded(
                  flex: 2,
                  child: Container(
                    width: double.infinity,
                    color: const Color(0xFFFF6B3D),
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.024,
                      horizontal: screenWidth * 0.08,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: AnimatedTextKit(
                            repeatForever: true,
                            pause: const Duration(milliseconds: 80),
                            animatedTexts: [
                              TypewriterAnimatedText(
                                "Create Account",
                                textStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: screenWidth * 0.12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -2,
                                ),
                                speed: const Duration(milliseconds: 180),
                              ),
                              TypewriterAnimatedText(
                                "Collaborate",
                                textStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: screenWidth * 0.12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -2,
                                ),
                                speed: const Duration(milliseconds: 180),
                              ),
                              TypewriterAnimatedText(
                                'Achieve More',
                                textStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: screenWidth * 0.12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -2,
                                ),
                                speed: const Duration(milliseconds: 180),
                              ),
                              TypewriterAnimatedText(
                                'Grow Together',
                                textStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: screenWidth * 0.12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -2,
                                ),
                                speed: const Duration(milliseconds: 180),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.001),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Join the coding community',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: screenWidth * 0.034,
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
                    color: Colors.white,
                    icon: Icons.person_outline,
                    label: "USERNAME",
                    child: TextField(
                      controller: username,
                      keyboardType: TextInputType.name,
                      style: _fieldStyle(screenWidth),
                      decoration: _fieldDecoration("your_username"),
                    ),
                  ),
                ),

                // Stripe 3: Email Field - Yellow
                Expanded(
                  flex: 2,
                  child: _buildInputStripe(
                    color: const Color(0xFFFFB84D),
                    icon: Icons.email_outlined,
                    label: "EMAIL",
                    child: TextField(
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      style: _fieldStyle(screenWidth),
                      decoration: _fieldDecoration("your.email@example.com"),
                    ),
                  ),
                ),

                // Stripe 4: Password Field - Red
                Expanded(
                  flex: 2,
                  child: _buildInputStripe(
                    color: const Color(0xFFE84855),
                    icon: Icons.lock_outline,
                    label: "PASSWORD",
                    child: TextField(
                      controller: password,
                      obscureText: true,
                      style: _fieldStyle(screenWidth),
                      decoration: _fieldDecoration("••••••••"),
                    ),
                  ),
                ),

                // Stripe 5: College Field - Pink
                Expanded(
                  flex: 2,
                  child: Container(
                    width: double.infinity,
                    color: const Color(0xFFE94196),
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02,
                      horizontal: screenWidth * 0.08,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.school_outlined, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'COLLEGE',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 2.2),
                            color: Colors.white,
                          ),
                          child: AutoCompleteField(con: clgname),
                        ),
                      ],
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
                                  'https://lstatsbackend-production.up.railway.app/leaderboard/refresh',
                                ),
                              );

                              await auth.register(
                                username.text,
                                email.text,
                                password.text,
                                clgname.text,
                              );

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Registration successful!"),
                                    backgroundColor: Color(0xFF6BCF7F),
                                  ),
                                );
                                Navigator.pop(context);
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(e.toString()),
                                    backgroundColor: const Color(0xFFE84855),
                                  ),
                                );
                              }
                            }
                          },
                    child: GestureDetector(
                      onTap: auth.isLoading
                          ? null
                          : () async {
                              try {
                                await auth.register(
                                  username.text.trim(),
                                  email.text.trim(),
                                  password.text.trim(),
                                  clgname.text,
                                );
                                if (auth.token != null && context.mounted) {
                                  setState(() {
                                    c = Colors.green;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Registeration Succesful !",
                                      ),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
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
                                    const SnackBar(
                                      content: Text("Something went wrong."),
                                      backgroundColor: Color(0xFFE84855),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Error: ${e.toString()}"),
                                      backgroundColor: const Color(0xFFE84855),
                                      behavior: SnackBarBehavior.floating,
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
                                  width: screenWidth * 0.07,
                                  height: screenWidth * 0.07,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 4,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'CREATE ACCOUNT',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: screenWidth * 0.045,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    SizedBox(width: screenWidth * 0.03),
                                    Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                      size: screenWidth * 0.07,
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  flex: 1,
                  child: Container(
                    width: double.infinity,
                    color: const Color(0xFFCCCCCC),
                    child: Center(
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
                            horizontal: screenWidth * 0.03,
                            vertical: screenHeight * 0.005,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Already have an account? Sign In',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: screenWidth * 0.035,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.arrow_outward,
                              color: Colors.black,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInputStripe({
    required Color color,
    required IconData icon,
    required String label,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      color: color,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2.2),
              color: Colors.white,
            ),
            child: child,
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFFCCCCCC),
        fontWeight: FontWeight.w500,
      ),
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }

  TextStyle _fieldStyle(double screenWidth) {
    return TextStyle(
      fontSize: screenWidth * 0.04,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    );
  }
}
