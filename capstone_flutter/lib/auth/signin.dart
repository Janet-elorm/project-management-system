import 'package:capstone_flutter/api_service/auth_service.dart';
import 'package:capstone_flutter/auth/login.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  void _signupUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final response = await _authService.signup(
        _firstNameController.text,
        _lastNameController.text,
        _emailController.text,
        _phoneController.text,
        _passwordController.text,
      );

      setState(() => _isLoading = false);

      if (response != null && response.containsKey("error")) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Signup Failed: ${response['error']}")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Signup Successful! Redirecting...")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 150.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Left-Side Image Section
              Expanded(
                child: Container(
                  height: double.infinity,
                  width: 350,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/Rectangle 12.png'),
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                  child: Align(
                    alignment: const Alignment(-1.8, 0.2),
                    child: Image.asset(
                      'assets/young man sitting in front of laptop.png',
                      fit: BoxFit.contain,
                      width: 300,
                      height: 300,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Right-Side Form Section
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Create Account",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // First Name & Last Name
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _firstNameController,
                                decoration: InputDecoration(
                                  labelText: 'First Name',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                                validator: (value) => value!.isEmpty ? "Required" : null,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: TextFormField(
                                controller: _lastNameController,
                                decoration: InputDecoration(
                                  labelText: 'Last Name',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                                validator: (value) => value!.isEmpty ? "Required" : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Email
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          validator: (value) => value!.isEmpty ? "Required" : null,
                        ),
                        const SizedBox(height: 20),

                        // Phone
                        TextFormField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            labelText: 'Phone No',
                            prefixIcon: const Icon(Icons.phone),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          validator: (value) => value!.isEmpty ? "Required" : null,
                        ),
                        const SizedBox(height: 20),

                        // Password
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: const Icon(Icons.visibility_off),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          validator: (value) => value!.length < 6 ? "Minimum 6 characters required" : null,
                        ),
                        const SizedBox(height: 20),

                        // Confirm Password
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: const Icon(Icons.visibility_off),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          validator: (value) {
                            if (value != _passwordController.text) {
                              return "Passwords do not match";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),

                        // Signup Button
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                onPressed: _signupUser,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE0E4EA),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Text('Create Account', style: TextStyle(color: Colors.black)),
                                ),
                              ),

                        const SizedBox(height: 20),

                        // Login Link
                        Center(
                          child: RichText(
                            text: TextSpan(
                              text: 'Already have an account? ',
                              style: const TextStyle(color: Colors.black),
                              children: [
                                TextSpan(
                                  text: 'Sign in',
                                  style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                                  recognizer: TapGestureRecognizer()..onTap = () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
