import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:capstone_flutter/api_service/auth_service.dart';
import 'package:capstone_flutter/auth/signin.dart';
import 'package:capstone_flutter/pages/dashboard.dart';
import 'package:http/http.dart' as http;
import 'package:capstone_flutter/pages/taskManager.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

   @override
  void initState() {
    super.initState();
    checkInviteLink(); // ✅ Run on app start
  }

  void checkInviteLink() async {
    final uri = Uri.base;
    final token = uri.queryParameters['token'];
    final projectId = uri.queryParameters['projectId'];

    if (token != null && projectId != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('invite_token', token);
      await prefs.setInt('invited_project_id', int.parse(projectId));
      print("✅ Saved invite token: $token and projectId: $projectId");
    }
  }

  Future<void> _storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  void _loginUser() async {
  if (_formKey.currentState!.validate()) {
    setState(() => _isLoading = true);
    try {
      final response = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      setState(() => _isLoading = false);

      if (response != null && response.containsKey("access_token")) {
        await _storeToken(response['access_token']);
        final prefs = await SharedPreferences.getInstance();

        // ✅ STEP 4: Check for invite token and project ID
        final inviteToken = prefs.getString('invite_token');
        final invitedProjectId = prefs.getInt('invited_project_id');

        if (inviteToken != null && invitedProjectId != null) {
          final acceptResponse = await http.get(
            Uri.parse('http://127.0.0.1:8000/invite/projects/accept-invite?token=$inviteToken'),
          );

          if (acceptResponse.statusCode == 200) {
            // ✅ Clean up and redirect
            await prefs.remove('invite_token');
            await prefs.remove('invited_project_id');

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TaskManagerPage(projectId: invitedProjectId),
              ),
            );
            return; // prevent fallthrough to dashboard
          } else {
            print("❌ Failed to accept invite: ${acceptResponse.body}");
          }
        }

        // ✅ Fallback if no invite
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardPage()),
        );
      } else {
        _showErrorSnackbar("Login Failed: Invalid credentials.");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackbar("An error occurred. Please try again.");
    }
  }
}

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 220, 225, 232),
      body: Center(
        child: Container(
          width: 1000,
          height: 600,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              // Left side - Illustration
              Expanded(
                flex: 1,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 151, 167, 186),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/undraw_taking-notes_4si1-removebg-preview.png',
                          width: 420,
                        ),
                      ),
                      Positioned(
                        top: 24,
                        left: 24,
                        child: Image.asset(
                          'assets/onboard-removebg-preview.png',
                          height: 40,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Right side - Login Form
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Welcome Back',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Email Input
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Email is required";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Password Input
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Password is required";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 30),

                            // Login Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _loginUser,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color.fromARGB(255, 151, 167, 186),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text('Sign in', style: TextStyle(color: Colors.white)),
                              ),
                            ),
                            const SizedBox(height: 24),

                            Center(
                              child: RichText(
                                text: TextSpan(
                                  text: 'Are you new? ',
                                  style: TextStyle(color: Colors.grey.shade600),
                                  children: [
                                    TextSpan(
                                      text: 'Create an Account',
                                      style: const TextStyle(
                                        color: Color.fromARGB(255, 151, 167, 186),
                                        fontWeight: FontWeight.bold,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const SignUpPage(),
                                            ),
                                          );
                                        },
                                    ),
                                  ],
                                ),
                              ),
                            )
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
      ),
    );
  }
}
