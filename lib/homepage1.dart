
import 'package:final_menu/Driver_HomePages/first_land_page_after_registration.dart';
import 'package:final_menu/Driver_initial-auth/driver_registration_page.dart';
import 'package:final_menu/Driver_initial-auth/initial_auth_field.dart';
import 'package:final_menu/homepage.dart';
import 'package:final_menu/login_screen/sign_in_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage1 extends StatelessWidget {
  final String pickupLatitude = '27.6508';
  final String pickupLongitude = '84.5142';
  final String deliveryLatitude = '27.6098';
  final String deliveryLongitude = '84.5119';
  final String videoUrl = 'https://www.youtube.com/video/Fpb5XtZb-DI'; 


  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }


  @override
  Widget build(BuildContext context) {
    final String? message = ModalRoute.of(context)?.settings.arguments as String?;
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        body: Center(
          child: Text('No user is logged in'),
        ),
      );
    }

    final String userId = currentUser.uid;
    CollectionReference users = FirebaseFirestore.instance.collection('users');

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
        String email = currentUser.email ?? 'No Email';

        return Scaffold(
          appBar: AppBar(
            title: Text('Home Page'),
            backgroundColor: Colors.purpleAccent,
          ),
          body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: constraints.maxWidth * 0.05),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: _buildCard(
                              context: context,
                              title: 'Book a Ride',
                              subtitle: 'Get a ride quickly',
                              color: Colors.pinkAccent,
                              icon: Icons.directions_car,
                              onTap: () {
                                String url =
                                    'https://www.openstreetmap.org/directions?engine=graphhopper_car&route=$pickupLatitude%2C$pickupLongitude%3B$deliveryLatitude%2C$deliveryLongitude';
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HomePage(url: url),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: _buildCard(
                              context: context,
                              title: 'Driver Mode',
                              subtitle: 'Start driving',
                              color: Colors.blueAccent,
                              icon: Icons.person,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DriverRegistrationPage(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 40),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: constraints.maxWidth * 0.05),
                      child: _buildUserDetailsCard(
                        context: context,
                        username: username,
                        email: email,
                        phoneNumber: phoneNumber,
                        avatarLetter: username.isNotEmpty ? username[0].toUpperCase() : 'U',
                      ),
                    ),

                    SizedBox(
                      height: 40,
                    ),

                    GestureDetector(
                      onTap: () => _launchURL(videoUrl),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: constraints.maxWidth * 0.05),
                        child: _buildhelp(
                          context: context,
                          username: username,
                          email: email,
                          phoneNumber: phoneNumber,
                          avatarLetter: username.isNotEmpty ? username[0].toUpperCase() : 'U',
                        ),
                      ),
                    ),


                    SizedBox(height: 40),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: constraints.maxWidth * 0.02),
                      child: _buildCard(
                        context: context,
                        title: 'Passenger Signout',
                        subtitle: 'Sign out safely',
                        color: Colors.redAccent,
                        icon: Icons.logout,
                        isFullWidth: true,
                        onTap: () {
                          FirebaseAuth.instance.signOut();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignInPage(),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
    bool isFullWidth = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipPath(
            clipper: TopRightRoundedClipper(),
            child: Container(
              width: isFullWidth ? MediaQuery.of(context).size.width * 0.9 : null,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 30),
                  Text(
                    title,
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: -20,
            right: -10,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 30,
              child: Icon(icon, size: 32, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserDetailsCard({
    required BuildContext context,
    required String username,
    required String email,
    required String phoneNumber,
    required String avatarLetter,
  }) {
    return GestureDetector(
      onTap: () {
        // Handle tap event for user details if needed
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipPath(
            clipper: TopRightRoundedClipper(),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 56, 224, 143),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 30),
                  Text(
                    'Username: $username',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Email: $email',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Phone: $phoneNumber',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: -20,
            right: -10,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 30,
              child: Text(
                avatarLetter,
                style: TextStyle(color: Colors.greenAccent, fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }


   Widget _buildhelp({
    required BuildContext context,
    required String username,
    required String email,
    required String phoneNumber,
    required String avatarLetter,
  }) {
    return GestureDetector(
      onTap: () {
        _launchURL(videoUrl);
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipPath(
            clipper: TopRightRoundedClipper(),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 236, 116, 236),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 30),
                  Text(
                    'Need Help ?',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "You can't find Your Place ?",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Help Us fill places you know so that it will help others too",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: -20,
            right: -10,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 30,
              child: Icon(Icons.help,size: 40,color: const Color.fromARGB(255, 236, 116, 236),),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Clipper to curve the top-right corner
class TopRightRoundedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, 0.0);
    path.lineTo(0.0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 20.0);
    path.arcToPoint(
      Offset(size.width - 20.0, 0.0),
      radius: Radius.circular(20.0),
      clockwise: false,
    );
    path.close();
    return path;
  }

  @override
 
  Path g(Size size) {
    var path = Path();
    path.lineTo(0.0, 0.0);
    path.lineTo(0.0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 20.0);
    path.arcToPoint(
      Offset(size.width - 20.0, 0.0),
      radius: Radius.circular(20.0),
      clockwise: false,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }}