import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:final_menu/Driver_HomePages/first_land_page_after_registration.dart';

class DriverRegistrationPage extends StatefulWidget {
  const DriverRegistrationPage({Key? key}) : super(key: key);

  @override
  _DriverRegistrationPageState createState() => _DriverRegistrationPageState();
}

class _DriverRegistrationPageState extends State<DriverRegistrationPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();  // Check if the user is already logged in
  }

  // Check if user is already registered and logged in
  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedEmail = prefs.getString('driverEmail');

    if (savedEmail != null) {
      // Email is already saved, navigate to DriverHomePage directly
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DriverHomePage()),
      );
    }
  }

  Future<void> _validateDriver() async {
    final String email = _emailController.text.trim();

    if (email.isEmpty) {
      _showErrorMessage('Please enter your email');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Check if the entered email matches the 'email' field in the 'vehicleData' collection
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('vehicleData')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Email exists in the collection, save it in SharedPreferences for persistent login
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('driverEmail', email);

        // Navigate to DriverHomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DriverHomePage()),
        );
      } else {
        // Email not found
        _showErrorMessage('Email not found. Please check and try again.');
      }
    } catch (e) {
      _showErrorMessage('Error validating driver: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your registered email:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _validateDriver,
                    child: const Text('Submit'),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
