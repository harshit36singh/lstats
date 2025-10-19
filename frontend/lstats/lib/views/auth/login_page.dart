import 'package:flutter/material.dart';
import 'package:lstats/viewmodels/auth_viewmodels.dart';
import 'package:lstats/views/auth/pages/pagenav.dart';
import 'package:lstats/views/auth/register_page.dart';
import 'package:provider/provider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  bool isLoading1 = false;
  Color signInColor = const Color(0xFFE84855);

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthViewModel>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = constraints.maxHeight;
            final screenWidth = constraints.maxWidth;

            return Column(
              children: [
                // Stripe 1: Welcome Header - Orange
                Expanded(
                  flex: 2,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.03,
                      horizontal: screenWidth * 0.08,
                    ),
                    color: const Color(0xFFFF6B3D),
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
                                "Welcome Back",
                                textStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: screenWidth * 0.12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -2,
                                ),
                                speed: const Duration(milliseconds: 180),
                              ),
                              TypewriterAnimatedText(
                                'Compare',
                                textStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: screenWidth * 0.12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -2,
                                ),
                                speed: const Duration(milliseconds: 180),
                              ),
                              TypewriterAnimatedText(
                                'Observe',
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
                        SizedBox(height: screenHeight * 0.01),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Sign in to continue',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Stripe 2: Email Field - White
                Expanded(
                  flex: 2,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02,
                      horizontal: screenWidth * 0.08,
                    ),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.email_outlined, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'USERNAME',
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
                          child: TextField(
                            controller: email,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'your.email@example.com',
                              hintStyle: TextStyle(
                                color: Color(0xFFCCCCCC),
                                fontWeight: FontWeight.w500,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Stripe 3: Password Field - Yellow
                Expanded(
                  flex: 2,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02,
                      horizontal: screenWidth * 0.08,
                    ),
                    color: const Color(0xFFFFB84D),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.lock_outline, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'PASSWORD',
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
                          child: TextField(
                            controller: password,
                            obscureText: true,
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                            decoration: const InputDecoration(
                              hintText: '••••••••',
                              hintStyle: TextStyle(
                                color: Color(0xFFCCCCCC),
                                fontWeight: FontWeight.w500,
                                letterSpacing: 2,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Stripe 4: Sign In Button - Red
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: auth.isLoading
                        ? null
                        : () async {
                            try {
                              await auth.login(
                                email.text.trim(),
                                password.text.trim(),
                              );

                              if (auth.token != null && context.mounted) {
                                setState(() {
                                  signInColor = const Color(0xFF6BCF7F);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Login successful!"),
                                    backgroundColor: Color(0xFF6BCF7F),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        MainNavPage(uname: email.text),
                                  ),
                                );
                              } else if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Wrong info. Please try again.",
                                    ),
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
                      color: signInColor,
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
                                    'SIGN IN',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: screenWidth * 0.05,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 2,
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

                // Stripe 5: Forgot Password - Pink
                Expanded(
                  flex: 1,
                  child: Container(
                    width: double.infinity,
                    color: const Color(0xFFE94196),
                    child: Center(
                      child: TextButton(
                        onPressed: () {},
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
                              'Forgot Password?',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.035,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.arrow_outward,
                              color: Colors.white,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Stripe 6: Create Account - Black
                Expanded(
                  flex: 1,
                  child: Container(
                    width: double.infinity,
                    color: Colors.black,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: TextStyle(
                            color: const Color(0xFF999999),
                            fontSize: screenWidth * 0.032,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.005),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFF6BCF7F),
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.06,
                              vertical: screenHeight * 0.01,
                            ),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterPage(),
                                ),
                              );
                            },
                            child: Text(
                              'CREATE ACCOUNT',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: screenWidth * 0.035,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ],
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
}
