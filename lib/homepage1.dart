
// import 'package:flutter/material.dart';
// import 'package:final_menu/Driver_HomePages/first_land_page_after_registration.dart';
// import 'package:final_menu/Driver_initial-auth/driver_registration_page.dart';
// import 'package:final_menu/Driver_initial-auth/initial_auth_field.dart';
// import 'package:final_menu/homepage.dart';
// import 'package:final_menu/login_screen/sign_in_page.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

// class HomePage1 extends StatelessWidget {
//   final String pickupLatitude = '27.6508';
//   final String pickupLongitude = '84.5142';
//   final String deliveryLatitude = '27.3383';
//   final String deliveryLongitude = '85.5020';

//   @override
//   Widget build(BuildContext context) {
//     final String? message = ModalRoute.of(context)?.settings.arguments as String?;

//     // Get the current logged-in user
//     final User? currentUser = FirebaseAuth.instance.currentUser;

//     if (currentUser == null) {
//       return Scaffold(
//         body: Center(
//           child: Text('No user is logged in'),
//         ),
//       );
//     }

//     final String userId = currentUser.uid; // Retrieve user ID from Firebase Auth
//     CollectionReference users = FirebaseFirestore.instance.collection('users');

//     // Display message if passed through navigation
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (message != null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(message)),
//         );
//       }
//     });

//     return FutureBuilder<DocumentSnapshot>(
//       future: users.doc(userId).get(),
//       builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(child: CircularProgressIndicator());
//         }

//         if (snapshot.hasError) {
//           return Center(child: Text("Error loading user data: ${snapshot.error}"));
//         }

//         if (!snapshot.hasData || !snapshot.data!.exists) {
//           return Center(child: Text("User data not found. User ID: $userId"));
//         }

//         Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
//         String username = data['username'] ?? 'Unknown User';
//         String phoneNumber = data['phone_number'] ?? 'No Phone Number';

//         return Scaffold(
//           appBar: AppBar(
//             title: Text('Home Page'),
//             backgroundColor: Colors.purpleAccent,
//           ),
//           body: Stack(
//             children: [
//               // Background image of an auto-rickshaw with opacity
//               Positioned.fill(
//                 child: Opacity(
//                   opacity: 0.1,
//                   child: Image.network(
//                     'https://i.postimg.cc/q7LWBLdM/autorickshaw.png',
//                     fit: BoxFit.fitWidth,
//                   ),
//                 ),
//               ),
//               // Main content with animated buttons
//               Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     // User Info Section (Avatar, Username, and Phone Number)
//                     CircleAvatar(
//                       radius: 40,
//                       backgroundColor: Colors.purple,
//                       child: Text(
//                         username.isNotEmpty ? username[0].toUpperCase() : '',
//                         style: TextStyle(fontSize: 30, color: Colors.white),
//                       ),
//                     ),
//                     SizedBox(height: 10),
//                     Text(
//                       username,
//                       style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//                     ),
//                     SizedBox(height: 5),
//                     Text(
//                       phoneNumber,
//                       style: TextStyle(fontSize: 16, color: Colors.grey[700]),
//                     ),
//                     SizedBox(height: 40),

//                     // Show Map Button with a map icon
//                     _buildAnimatedButton(
//                       context: context,
//                       buttonText: 'Show Map',
//                       heroTag: 'showMapHero',
//                       iconData: Icons.map, // Map icon
//                       onPressed: () {
//                         String url = 'https://www.openstreetmap.org/directions?engine=graphhopper_car&route=$pickupLatitude%2C$pickupLongitude%3B$deliveryLatitude%2C$deliveryLongitude';
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => HomePage(url: url),
//                           ),
//                         );
//                       },
//                     ),
//                     SizedBox(height: 20),

//                     // Sign-Out Button with a logout icon
//                     _buildAnimatedButton(
//                       context: context,
//                       buttonText: 'Sign-Out',
//                       heroTag: 'signOutHero',
//                       iconData: Icons.logout, // Logout icon
//                       onPressed: () {
//                         FirebaseAuth.instance.signOut();
//                         Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => SignInPage(),
//                           ),
//                         );
//                       },
//                     ),
//                     SizedBox(height: 20),

//                     // Driver Signup Button with a person icon
//                     _buildAnimatedButton(
//                       context: context,
//                       buttonText: 'Driver Signup Page',
//                       heroTag: 'driverSignupHero',
//                       iconData: Icons.person_add, // Person add icon
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => DriverAuthPage(),
//                           ),
//                         );
//                       },
//                     ),
//                     SizedBox(height: 20),

//                     // Driver Register Button with a registration icon
//                     _buildAnimatedButton(
//                       context: context,
//                       buttonText: 'Driver Register Page',
//                       heroTag: 'driverRegisterHero',
//                       iconData: Icons.app_registration, // Registration icon
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => DriverAuthPage(),
//                           ),
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // Function to build an animated button with hero transition and icon
//   Widget _buildAnimatedButton({
//     required BuildContext context,
//     required String buttonText,
//     required String heroTag,
//     required IconData iconData, // New parameter to pass icon data
//     required VoidCallback onPressed,
//   }) {
//     return Hero(
//       tag: heroTag,
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           foregroundColor: Colors.white,
//           backgroundColor: Colors.purpleAccent,
//           shadowColor: Colors.purple,
//           elevation: 8,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20.0),
//           ),
//           padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
//         ),
//         onPressed: onPressed,
//         child: Row( // Using Row to place icon and text side by side
//           mainAxisSize: MainAxisSize.min, // Adjusts the button size to its content
//           children: [
//             Icon(iconData, size: 24), // Icon for the button
//             SizedBox(width: 10), // Space between the icon and the text
//             Text(
//               buttonText,
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:final_menu/Driver_HomePages/first_land_page_after_registration.dart';
import 'package:final_menu/Driver_initial-auth/driver_registration_page.dart';
import 'package:final_menu/Driver_initial-auth/initial_auth_field.dart';
import 'package:final_menu/homepage.dart';
import 'package:final_menu/login_screen/sign_in_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:flutter/material.dart'; // Ensure this import is included

class HomePage1 extends StatelessWidget {
  final String pickupLatitude = '27.6508';
  final String pickupLongitude = '84.5142';
  final String deliveryLatitude = '27.6098';
  final String deliveryLongitude = '84.5119';

  @override
  Widget build(BuildContext context) {
    final String? message = ModalRoute.of(context)?.settings.arguments as String?;

    // Get the current logged-in user
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        body: Center(
          child: Text('No user is logged in'),
        ),
      );
    }

    final String userId = currentUser.uid; // Retrieve user ID from Firebase Auth
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    // Display message if passed through navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    });

    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(userId).get(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text("Error loading user data: ${snapshot.error}")),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            body: Center(child: Text("User data not found. User ID: $userId")),
          );
        }

        Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
        String username = data['username'] ?? 'Unknown User';
        String phoneNumber = data['phone_number'] ?? 'No Phone Number';

        return Scaffold(
          appBar: AppBar(
            title: Text('Home Page'),
            backgroundColor: Colors.purpleAccent,
          ),
          body: SingleChildScrollView(
            child: Stack(
              children: [
                // Background image of an auto-rickshaw with opacity
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.1,
                    child: Image.network(
                      'https://i.postimg.cc/q7LWBLdM/autorickshaw.png',
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
                // Main content with Passenger and Driver Mode
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 30,
                      ),
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: const Color.fromARGB(255, 219, 100, 240),
                        child: Text(
                          username.isNotEmpty ? username[0].toUpperCase() : '',
                          style: TextStyle(fontSize: 30, color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        username,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Text(
                        phoneNumber,
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                      SizedBox(height: 40),

                      _buildSectionTitle('Passenger Mode'),
                      _buildPassengerMode(context),

                      SizedBox(height: 40),

                      Divider(
                        thickness: 2,
                        color: Colors.grey,
                        indent: 20,
                        endIndent: 20,
                      ),

                      _buildSectionTitle('Driver Mode'),
                      _buildDriverMode(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }

  Widget _buildPassengerMode(BuildContext context) {
    return Column(
      children: [
        _buildAnimatedButton(
          context: context,
          buttonText: 'Want a ride ?',
          heroTag: 'showMapHero',
          iconData: Icons.car_rental, // Map icon
          onPressed: () {
            String url = 'https://www.openstreetmap.org/directions?engine=graphhopper_car&route=$pickupLatitude%2C$pickupLongitude%3B$deliveryLatitude%2C$deliveryLongitude';
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(url: url),
              ),
            );
          },
        ),
        SizedBox(height: 20),
        _buildAnimatedButton(
          context: context,
          buttonText: 'Sign Out',
          heroTag: 'signOutHero',
          iconData: Icons.logout, 
          onPressed: () {
            FirebaseAuth.instance.signOut();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => SignInPage(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDriverMode(BuildContext context) {
    return Column(
      children: [
        _buildAnimatedButton(
          context: context,
          buttonText: 'Driver Signup Page',
          heroTag: 'driverSignupHero',
          iconData: Icons.person_add, 
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DriverAuthPage(),
              ),
            );
          },
        ),
        SizedBox(height: 20),
        _buildAnimatedButton(
          context: context,
          buttonText: 'Driver Register Page',
          heroTag: 'driverRegisterHero',
          iconData: Icons.app_registration, 
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DriverAuthPage(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAnimatedButton({
    required BuildContext context,
    required String buttonText,
    required String heroTag,
    required IconData iconData, 
    required VoidCallback onPressed,
  }) {
    return Hero(
      tag: heroTag,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: const Color.fromARGB(255, 211, 105, 230),
          shadowColor: Colors.purple,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        ),
        onPressed: onPressed,
        child: Row( 
          mainAxisSize: MainAxisSize.min, 
          children: [
            Icon(iconData, size: 24), 
            SizedBox(width: 10), 
            Text(
              buttonText,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
