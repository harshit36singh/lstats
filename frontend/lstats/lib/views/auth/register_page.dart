import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lstats/viewmodels/auth_viewmodels.dart';
import 'package:lstats/widgets/autocomplete.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart' hide LinearGradient;

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

  // Rive controllers
  StateMachineController? _controller;

  // State machine inputs
  SMIInput<bool>? _isChecking;
  SMIInput<bool>? _isHandsUp;
  SMIInput<double>? _numLook;
  SMITrigger? _trigSuccess;
  SMITrigger? _trigFail;

  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // Username focus listener
    _usernameFocusNode.addListener(() {
      if (_isChecking != null) {
        _isChecking!.value = _usernameFocusNode.hasFocus;
        if (_usernameFocusNode.hasFocus && _isHandsUp != null) {
          _isHandsUp!.value = false;
        }
      }
    });

    // Email focus listener
    _emailFocusNode.addListener(() {
      if (_isChecking != null) {
        _isChecking!.value = _emailFocusNode.hasFocus;
        if (_emailFocusNode.hasFocus && _isHandsUp != null) {
          _isHandsUp!.value = false;
        }
      }
    });

    // Password focus listener
    _passwordFocusNode.addListener(() {
      if (_isHandsUp != null) {
        _isHandsUp!.value = _passwordFocusNode.hasFocus;
        if (_passwordFocusNode.hasFocus && _isChecking != null) {
          _isChecking!.value = false;
        }
      }
    });

    // Username text listener for eye tracking
    username.addListener(() {
      if (_numLook != null && _usernameFocusNode.hasFocus) {
        _numLook!.value = username.text.length.toDouble() * 3;
      }
    });

    // Email text listener for eye tracking
    email.addListener(() {
      if (_numLook != null && _emailFocusNode.hasFocus) {
        _numLook!.value = email.text.length.toDouble() * 3;
      }
    });
  }

  void _onRiveInit(Artboard artboard) {
    final possibleNames = [
      'State Machine 1',
      'Login',
      'state_machine',
      'SM',
      'StateMachine',
    ];

    StateMachineController? controller;
    for (var name in possibleNames) {
      controller = StateMachineController.fromArtboard(artboard, name);
      if (controller != null) {
        break;
      }
    }

    if (controller != null) {
      artboard.addController(controller);
      _controller = controller;
      _findInputs(controller);
    }
  }

  void _findInputs(StateMachineController controller) {
    _isChecking = controller.findInput<bool>('isFocus');
    _isHandsUp = controller.findInput<bool>('IsPassword');
    _numLook = controller.findInput<double>('eye_track');

    var successInput = controller.findInput<bool>('login_success');
    if (successInput != null && successInput is SMITrigger) {
      _trigSuccess = successInput;
    }

    var failInput = controller.findInput<bool>('login_fail');
    if (failInput != null && failInput is SMITrigger) {
      _trigFail = failInput;
    }
  }

  @override
  void dispose() {
    _usernameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    username.dispose();
    email.dispose();
    password.dispose();
    clgname.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthViewModel>(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A), // Dark LeetCode background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.06),

                const Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFFFA116), // LeetCode orange
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Join the coding community",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFFB3B3B3), // Light gray for subtitles
                  ),
                ),

                const SizedBox(height: 20),

                // Cat Animation
                SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: RiveAnimation.asset(
                    'assets/a.riv',
                    fit: BoxFit.contain,
                    onInit: _onRiveInit,
                  ),
                ),

                _buildTextField(
                  controller: username,
                  focusNode: _usernameFocusNode,
                  hint: "Username",
                  icon: Icons.person_outline,
                  isPassword: false,
                ),

                const SizedBox(height: 20),

                _buildTextField(
                  controller: email,
                  focusNode: _emailFocusNode,
                  hint: "Email",
                  icon: Icons.email_outlined,
                  isPassword: false,
                ),

                const SizedBox(height: 20),

                _buildTextField(
                  controller: password,
                  focusNode: _passwordFocusNode,
                  hint: "Password",
                  icon: Icons.lock_outline,
                  isPassword: true,
                ),

                const SizedBox(height: 20),

                // College Autocomplete Field
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D2D2D),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF3D3D3D),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: AutoCompleteField(con: clgname),
                ),

                const SizedBox(height: 32),

                // Register Button
                auth.isLoading
                    ? Container(
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFFFA116), // LeetCode orange
                              Color(0xFFFF6B6B), // Complementary red-pink
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF1A1A1A),
                            strokeWidth: 3,
                          ),
                        ),
                      )
                    : Material(
                        elevation: 8,
                        borderRadius: BorderRadius.circular(16),
                        shadowColor: const Color(0xFFFFA116).withOpacity(0.3),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () async {
                            _usernameFocusNode.unfocus();
                            _emailFocusNode.unfocus();
                            _passwordFocusNode.unfocus();

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

                              if (_trigSuccess != null) {
                                _trigSuccess!.fire();
                              }

                              await Future.delayed(
                                const Duration(milliseconds: 1500),
                              );

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Registration successful!"),
                                    backgroundColor: Color(
                                      0xFF00C853,
                                    ), // Success green
                                  ),
                                );
                                Navigator.pop(context);
                              }
                            } catch (e) {
                              if (_trigFail != null) {
                                _trigFail!.fire();
                              }

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(e.toString()),
                                    backgroundColor: const Color(
                                      0xFFFF6B6B,
                                    ), // Error red-pink
                                  ),
                                );
                              }
                            }
                          },
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFFFA116), // LeetCode orange
                                  Color(0xFFFF6B6B), // Complementary red-pink
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Text(
                                "Create Account",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(
                                    0xFF1A1A1A,
                                  ), // Dark text on bright button
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(
                        color: Color(0xFFB3B3B3), // Light gray
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        "Sign In",
                        style: TextStyle(
                          color: Color(0xFFFFA116), // LeetCode orange
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required IconData icon,
    required bool isPassword,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D), // Dark card background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF3D3D3D), // Subtle border
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: isPassword,
        keyboardType: isPassword
            ? TextInputType.text
            : TextInputType.emailAddress,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFFEFEFEF),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color(0xFF6B6B6B),
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(icon, color: const Color(0xFFFFA116), size: 22),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFFFFA116),
              width: 2,
            ), // LeetCode orange focus
          ),
          filled: true,
          fillColor: const Color(0xFF2D2D2D),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}
