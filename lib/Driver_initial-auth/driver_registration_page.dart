import 'package:final_menu/Driver_initial-auth/initial_auth_field.dart';
import 'package:final_menu/login_screen/sign_in_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
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
   Color _color = const Color.fromARGB(255, 189, 62, 228);

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
       _color = _color == const Color.fromARGB(255, 189, 62, 228)
            ? const Color.fromARGB(255, 14, 199, 54)
            : const Color.fromARGB(255, 189, 62, 228);
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
             GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DriverAuthPage()));
              },
              child: const Text(
                ' New Driver? Register Here (Driver Mode)',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor: Color.fromARGB(255, 101, 12, 185)),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            

            SizedBox(
              height: 20,
            ),
            const Text(
              'Enter your registered email:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                        prefixIconColor: const Color.fromARGB(255, 187, 109, 201),
                        labelText: 'Enter your E-mail',
                        prefixIcon: Icon(Icons.email),
                        hintText: 'johndoe@gmail.com',
                        filled: true,
                        fillColor: Colors.white12,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 182, 116, 194)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 200, 54, 244)),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(18)),
                        ),
                      ),
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              
            ),




           



                    
            const SizedBox(height: 38),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                // : ElevatedButton(
                //     onPressed: _validateDriver,
                //     child: const Text('Submit'),),
               : ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      child: GestureDetector(
                        onTap: _validateDriver,
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.07,
                          width: MediaQuery.of(context).size.width,
                          color: _color,
                          child: const Center(
                            child: Text(
                              'Submit',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

            const SizedBox(height: 38),

                     GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignInPage()),
                        );
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.02),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              color: const Color.fromARGB(255, 200, 54, 244),
                              width: 2),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Passenger Mode',
                              style: GoogleFonts.amaticSc(
                                fontSize: MediaQuery.of(context).size.height * 0.04,
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 200, 54, 244),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
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
