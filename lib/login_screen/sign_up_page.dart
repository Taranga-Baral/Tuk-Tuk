// import 'package:final_menu/homepage.dart';
// import 'package:final_menu/homepage1.dart';
// import 'package:final_menu/login_screen/sign_in_page.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_fonts/google_fonts.dart';

// class RegistrationPage extends StatefulWidget {
//   @override
//   _RegistrationPageState createState() => _RegistrationPageState();
// }

// class _RegistrationPageState extends State<RegistrationPage> {
//   final _formKey = GlobalKey<FormState>();
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   bool _obscureText = true;
//   final _usernameController = TextEditingController();
//   final _mobileController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   Color _color = const Color.fromARGB(255, 189, 62, 228);

//   void _register() async {
//     if (_formKey.currentState!.validate()) {
//       try {
//         final UserCredential userCredential =
//     await _auth.createUserWithEmailAndPassword(
//   email: _emailController.text,
//   password: _passwordController.text,  // Corrected to use the password controller
// );

//         // If sign in is successful
//         if (userCredential.user != null) {
//           // Show Snackbar
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Sign Up Successful'),
//               duration: Duration(seconds: 1),
//             ),
//           );

//           // Navigate to HomePage after 1 second
//           Future.delayed(Duration(seconds: 1), () {
//             Navigator.of(context).pushReplacement(
//               MaterialPageRoute(
//                   builder: (context) =>
//                       HomePage1()), // Replace with your actual homepage widget
//             );
//           });
//           setState(() {
//             _color = _color == const Color.fromARGB(255, 189, 62, 228)
//                 ? const Color.fromARGB(255, 14, 199, 54)
//                 : const Color.fromARGB(255, 189, 62, 228);
//           });
//         }
//       } catch (e) {
//         print('Error Signing Up: $e');
//         // Handle sign in errors here
//         // Optionally show an error dialog to the user
//         showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: Text('Sign Up Failed'),
//             content: Text(
//                 'Either email is already taken or the format is incorrect'),
//             actions: <Widget>[
//               TextButton(
//                 child: Text('OK'),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//               ),
//             ],
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     var screenHeight = MediaQuery.of(context).size.height;
//     var screenWidth = MediaQuery.of(context).size.width;
//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: Size(screenWidth, screenHeight * 0.2),
//         child: ClipRRect(
//           borderRadius: const BorderRadius.only(
//               bottomLeft: Radius.circular(28),
//               bottomRight: Radius.circular(28)),
//           child: Container(
//             height: screenHeight * 0.42,
//             width: screenWidth,
//             color: const Color.fromARGB(255, 200, 54, 244),
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [

//                   Opacity(
//                     opacity: 0.8,
//                     child: const Image(
//                       image: NetworkImage(
//                           "https://i.postimg.cc/j27Q02yg/auto-removebg-preview.png"),
//                       height: 100,
//                       width: 130,
//                     ),
//                   ),

//                   SizedBox(
//                     height: 12,
//                   ),

//                   GestureDetector(
//                     onTap: () {
//                       Navigator.pushReplacement(context,
//                           MaterialPageRoute(builder: (context) => SignInPage()));
//                     },
//                     child: const Text(
//                       " Already? Sign In Here.",
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.w600,
//                           decoration: TextDecoration.underline,
//                           decorationColor: Colors.white),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             children: <Widget>[
//               SizedBox(
//                 height: 14,
//               ),
//               const Text(
//                 "Sign up",
//                 style: TextStyle(
//                   color: Color.fromARGB(255, 163, 66, 192),
//                   fontSize: 38,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               // ignore: prefer_const_constructors
//               SizedBox(
//                 height: 5,
//               ),

//               Padding(padding: EdgeInsets.all(12),child: Form(
//                 key: _formKey,
//                 child: Column(children: [
//                   TextFormField(
//                   controller: _usernameController,
//                   decoration: const InputDecoration(
//                       labelText: "Enter your Username",
//                       prefixIcon: Icon(Icons.person_2),
//                       hintText: "Taranga Baral",
//                       filled: true,
//                       fillColor: Colors.white12,
//                       prefixIconColor: Color.fromARGB(255, 187, 109, 201),
//                       enabledBorder: OutlineInputBorder(
//                         borderSide: BorderSide(
//                           color: Color.fromARGB(255, 182, 116, 194),
//                         ),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                           borderSide:
//                               BorderSide(color: Color.fromARGB(255, 200, 54, 244))),
//                       border: OutlineInputBorder(
//                           borderRadius: BorderRadius.all(Radius.circular(18)))),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter a username';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(
//                   height: 20,
//                 ),
//                 TextFormField(
//                   keyboardType: TextInputType.number,
//                   controller: _mobileController,
//                   decoration: const InputDecoration(
//                       labelText: "Enter your Mobile Number",
//                       prefixIcon: Icon(Icons.phone),
//                       hintText: "98********",
//                       filled: true,
//                       fillColor: Colors.white12,
//                       prefixIconColor: Color.fromARGB(255, 187, 109, 201),
//                       enabledBorder: OutlineInputBorder(
//                         borderSide: BorderSide(
//                           color: Color.fromARGB(255, 182, 116, 194),
//                         ),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                           borderSide:
//                               BorderSide(color: Color.fromARGB(255, 200, 54, 244))),
//                       border: OutlineInputBorder(
//                           borderRadius: BorderRadius.all(Radius.circular(18)))),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter a mobile phone number';
//                     } else if (value.length < 10 || value.length > 10) {
//                       return "Please Enter Valid Mobile Number";
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(
//                   height: 20,
//                 ),
//                 TextFormField(
//                   controller: _emailController,
//                   decoration: const InputDecoration(
//                       labelText: "Enter your E-mail",
//                       prefixIcon: Icon(Icons.email),
//                       hintText: "johndoe@gmail.com",
//                       filled: true,
//                       fillColor: Colors.white12,
//                       prefixIconColor: Color.fromARGB(255, 187, 109, 201),
//                       enabledBorder: OutlineInputBorder(
//                         borderSide: BorderSide(
//                           color: Color.fromARGB(255, 182, 116, 194),
//                         ),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                           borderSide:
//                               BorderSide(color: Color.fromARGB(255, 200, 54, 244))),
//                       border: OutlineInputBorder(
//                           borderRadius: BorderRadius.all(Radius.circular(18)))),
//                   validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter an email';
//                       }
//                       return null;
//                     },
//                 ),
//                 const SizedBox(
//                   height: 20,
//                 ),
//                 TextFormField(
//                   controller: _passwordController,
//                   obscureText: _obscureText,
//                   decoration: InputDecoration(
//                       labelText: "Enter your Password",
//                       prefixIcon: const Icon(Icons.password),
//                       filled: true,
//                       fillColor: Colors.white12,
//                       prefixIconColor: const Color.fromARGB(255, 187, 109, 201),
//                       suffixIconColor: const Color.fromARGB(255, 180, 113, 192),
//                       suffixIcon: IconButton(
//                         icon: Icon(
//                             _obscureText ? Icons.visibility_off : Icons.visibility),
//                         onPressed: () {
//                           setState(() {
//                             _obscureText = !_obscureText;
//                           });
//                         },
//                       ),
//                       enabledBorder: const OutlineInputBorder(
//                         borderSide: BorderSide(
//                           color: Color.fromARGB(255, 182, 116, 194),
//                         ),
//                       ),
//                       focusedBorder: const OutlineInputBorder(
//                           borderSide:
//                               BorderSide(color: Color.fromARGB(255, 200, 54, 244))),
//                       border: const OutlineInputBorder(
//                           borderRadius: BorderRadius.all(Radius.circular(18)))),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter a password';
//                     } else if (value.length < 6) {
//                       return 'Password must be at least 6 characters long';
//                     }
//                     return null;
//                   },
//                 ),
//                 SizedBox(height: 38),
//                 ClipRRect(
//                   borderRadius: const BorderRadius.all(Radius.circular(12)),
//                   child: GestureDetector(
//                     onTap: _register,
//                     child: Container(
//                       height: screenHeight * 0.07,
//                       width: screenWidth,
//                       color: _color,
//                       child: const Center(
//                         child: Text(
//                           "Register",
//                           style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 26,
//                               fontWeight: FontWeight.w600),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 30,
//                 ),
//                 Container(
//                   width: screenWidth * 0.9,
//                   padding: EdgeInsets.all(screenHeight * 0.02),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     border: Border.all(
//                         color: const Color.fromARGB(255, 200, 54, 244), width: 2),
//                     borderRadius: BorderRadius.circular(10),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.5),
//                         spreadRadius: 2,
//                         blurRadius: 5,
//                         offset: const Offset(0, 3),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "Notice",
//                         style: GoogleFonts.amaticSc(
//                           fontSize: screenHeight * 0.04,
//                           fontWeight: FontWeight.bold,
//                           color: const Color.fromARGB(255, 200, 54, 244),
//                         ),
//                       ),
//                       SizedBox(height: screenHeight * 0.008),
//                       Text(
//                         "We accept E-sewa, Khalti, IME Pay, Credit Card",
//                         style: TextStyle(
//                           fontSize: screenHeight * 0.02,
//                           color: Colors.black54,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 ],),
//               ),)
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_menu/Driver_initial-auth/driver_registration_page.dart';
import 'package:final_menu/Driver_initial-auth/initial_auth_field.dart';
import 'package:final_menu/homepage.dart';
import 'package:final_menu/homepage1.dart';
import 'package:final_menu/login_screen/sign_in_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Firestore instance
  bool _obscureText = true;
  final _usernameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  Color _color = const Color.fromARGB(255, 189, 62, 228);

  void _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        final UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // If sign in is successful
        if (userCredential.user != null) {
          // Store additional user information in Firestore
          final uid = userCredential.user!.uid;
          await FirebaseFirestore.instance.collection('users').doc(uid).set({
            'username': _usernameController.text,
            'phone_number': _mobileController.text,
            'email': _emailController.text,
          });

          // Show Snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sign Up Successful'),
              duration: Duration(seconds: 1),
            ),
          );

          // Navigate to HomePage after 1 second
          Future.delayed(Duration(seconds: 1), () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                  builder: (context) =>
                      HomePage1()), // Replace with your actual homepage widget
            );
          });

          setState(() {
            _color = _color == const Color.fromARGB(255, 189, 62, 228)
                ? const Color.fromARGB(255, 14, 199, 54)
                : const Color.fromARGB(255, 189, 62, 228);
          });
        }
      } catch (e) {
        print('Error Signing Up: $e');
        // Handle sign in errors here
        // Optionally show an error dialog to the user
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Sign Up Failed'),
            content: Text(
                'Either email is already taken or the format is incorrect'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(screenWidth, screenHeight * 0.2),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28)),
          child: Container(
            height: screenHeight * 0.42,
            width: screenWidth,
            color: const Color.fromARGB(255, 200, 54, 244),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Opacity(
                    opacity: 0.8,
                    child: const Image(
                      image: NetworkImage(
                          'https://i.postimg.cc/j27Q02yg/auto-removebg-preview.png'),
                      height: 100,
                      width: 130,
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignInPage()));
                    },
                    child: const Text(
                      ' Already? Sign In Here.',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 14,
              ),
              const Text(
                'Sign up',
                style: TextStyle(
                  color: Color.fromARGB(255, 163, 66, 192),
                  fontSize: 38,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Padding(
                padding: EdgeInsets.all(12),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Enter your Username',
                          prefixIcon: Icon(Icons.person_2),
                          hintText: 'Taranga Baral',
                          filled: true,
                          fillColor: Colors.white12,
                          prefixIconColor: Color.fromARGB(255, 187, 109, 201),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 182, 116, 194),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 200, 54, 244)),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18)),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a username';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        controller: _mobileController,
                        decoration: const InputDecoration(
                          labelText: 'Enter your Mobile Number',
                          prefixIcon: Icon(Icons.phone),
                          hintText: '98********',
                          filled: true,
                          fillColor: Colors.white12,
                          prefixIconColor: Color.fromARGB(255, 187, 109, 201),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 182, 116, 194),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 200, 54, 244)),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18)),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a mobile phone number';
                          } else if (value.length < 10 || value.length > 10) {
                            return 'Please Enter Valid Mobile Number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Enter your E-mail',
                          prefixIcon: Icon(Icons.email),
                          hintText: 'johndoe@gmail.com',
                          filled: true,
                          fillColor: Colors.white12,
                          prefixIconColor: Color.fromARGB(255, 187, 109, 201),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 182, 116, 194),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 200, 54, 244)),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18)),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          labelText: 'Enter your Password',
                          prefixIcon: const Icon(Icons.password),
                          filled: true,
                          fillColor: Colors.white12,
                          prefixIconColor:
                              const Color.fromARGB(255, 187, 109, 201),
                          suffixIconColor:
                              const Color.fromARGB(255, 180, 113, 192),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureText
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 182, 116, 194),
                            ),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 200, 54, 244)),
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18)),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          } else if (value.length < 6) {
                            return 'Password must be at least 6 characters long';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 38),
                      ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12)),
                        child: GestureDetector(
                          onTap: _register,
                          child: Container(
                            height: screenHeight * 0.07,
                            width: screenWidth,
                            color: _color,
                            child: const Center(
                              child: Text(
                                'Register',
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
                      const SizedBox(height: 25),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DriverAuthPage()),
                          );
                        },
                        child: Container(
                          width: screenWidth * 0.9,
                          padding: EdgeInsets.all(screenHeight * 0.02),
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
                                'Driver Mode',
                                style: GoogleFonts.amaticSc(
                                  fontSize: screenHeight * 0.04,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      const Color.fromARGB(255, 200, 54, 244),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
