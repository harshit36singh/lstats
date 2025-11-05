import 'package:flutter/material.dart';
import 'package:lstats/viewmodels/auth_viewmodels.dart';
import 'package:lstats/views/auth/pages/loadingindicator.dart';
import 'package:lstats/views/auth/pages/pagenav.dart';
import 'package:lstats/views/auth/register_page.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

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
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.amber,
                  border: Border(
                    bottom: BorderSide(color: Colors.black, width: 6),
                  ),
                ),
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 4),
                      ),
                      child: const Icon(
                        Icons.login,
                        size: 60,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "WELCOME BACK",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -2,
                        height: 1,
                        shadows: [
                          Shadow(
                            color: Colors.white,
                            offset: Offset(3, 3),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                      ),
                      child: const Text(
                        'SIGN IN TO CONTINUE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Email Field
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF00D4FF),
                  border: Border(
                    bottom: BorderSide(color: Colors.black, width: 4),
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.black,
                          ),
                          child: const Icon(
                            Icons.email,
                            color: Color(0xFF00D4FF),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'USERNAME',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 3),
                        color: Colors.white,
                      ),
                      child: TextField(
                        controller: email,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'your.email@example.com',
                          hintStyle: TextStyle(
                            color: Color(0xFFCCCCCC),
                            fontWeight: FontWeight.w600,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Password Field
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF3366),
                  border: Border(
                    bottom: BorderSide(color: Colors.black, width: 4),
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.black,
                          ),
                          child: const Icon(
                            Icons.lock,
                            color: Color(0xFFFF3366),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'PASSWORD',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 3),
                        color: Colors.white,
                      ),
                      child: TextField(
                        controller: password,
                        obscureText: true,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                        decoration: const InputDecoration(
                          hintText: '••••••••',
                          hintStyle: TextStyle(
                            color: Color(0xFFCCCCCC),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Sign In Button
              GestureDetector(
                onTap: auth.isLoading
                    ? null
                    : () async {
                        try {
                          await auth.login(
                            email.text.trim(),
                            password.text.trim(),
                          );

                          if (auth.token != null && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  "LOGIN SUCCESSFUL!",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                  ),
                                ),
                                backgroundColor: const Color(0xFF00E676),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                    color: Colors.black,
                                    width: 3,
                                  ),
                                  borderRadius: BorderRadius.zero,
                                ),
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
                              SnackBar(
                                content: const Text(
                                  "WRONG CREDENTIALS!",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                  ),
                                ),
                                backgroundColor: const Color(0xFFFF3366),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                    color: Colors.black,
                                    width: 3,
                                  ),
                                  borderRadius: BorderRadius.zero,
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Something went wrong ",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                  ),
                                ),
                                backgroundColor: const Color(0xFFFF3366),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                    color: Colors.black,
                                    width: 3,
                                  ),
                                  borderRadius: BorderRadius.zero,
                                ),
                              ),
                            );
                          }
                        }
                      },
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFD700),
                    border: Border(
                      bottom: BorderSide(color: Colors.black, width: 6),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: auth.isLoading
                      ? Center(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.black, width: 3),
                            ),
                            child: const SizedBox(
                              width: 32,
                              height: 32,
                              child: BrutalistLoadingIndicator()
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: Colors.black,
                              ),
                              child: const Icon(
                                Icons.arrow_forward,
                                color: Color(0xFFFFD700),
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 20),
                            const Text(
                              'SIGN IN',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                                shadows: [
                                  Shadow(
                                    color: Colors.white,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              // Forgot Password
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF6C5CE7),
                  border: Border(
                    bottom: BorderSide(color: Colors.black, width: 4),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      // TODO: Implement forgot password
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'FORGOT PASSWORD?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
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

              // Create Account
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const Text(
                      "DON'T HAVE AN ACCOUNT?",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E676),
                          border: Border.all(color: Colors.black, width: 3),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person_add,
                              color: Colors.black,
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'CREATE ACCOUNT',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}