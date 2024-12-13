import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:new_gycc/dashboardPage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  Future<void> _login() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showErrorDialog("Please enter both username and password.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch users from Firebase where username matches
      Query query = _databaseRef.child("User").orderByChild("username").equalTo(username);
      DataSnapshot snapshot = await query.get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> users = snapshot.value as Map<dynamic, dynamic>;

        for (var userId in users.keys) {

          var user = users[userId];

          // Check if the password matches (consider hashed passwords)
          if (user["password"] == password) {
            // Login successful
            setState(() {
              _isLoading = false;
            });

            // Navigate to the dashboard with userId
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (BuildContext context) => DashboardPage(id: userId)),
            );
            return;
          }
        }
      }

      // If no match found
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog("Invalid username or password.");
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog("An error occurred. Please try again. " + error.toString());
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Disable resizing when the keyboard appears
      body: Stack(
        children: [
          // Main Content
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 130),
                  // App Logo
                  Image.asset(
                    'assets/logo.png', // Replace with your logo file path
                    height: 170,
                  ),
                  const SizedBox(height: 20),
                  // Login Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3E70A7),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              hintText: 'Username',
                              hintStyle: const TextStyle(color: Colors.black),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              hintText: 'Password',
                              hintStyle: const TextStyle(color: Colors.black),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.black,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF86B8DF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                            )
                                : const Text('Login', style: TextStyle(color: Colors.black)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          // Bottom Illustration (Fixed)
          Align(
            alignment: Alignment.bottomCenter,
            child: Image.asset(
              'assets/illustration.png', // Replace with your illustration file path
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
