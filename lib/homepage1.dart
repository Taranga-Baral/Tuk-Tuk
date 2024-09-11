//homepage1 is the page to land after auth
import 'package:final_menu/Driver_HomePages/first_land_page_after_registration.dart';
import 'package:final_menu/Driver_initial-auth/driver_registration_page.dart';
import 'package:final_menu/Driver_initial-auth/initial_auth_field.dart';
import 'package:final_menu/homepage.dart';
import 'package:final_menu/login_screen/sign_in_page.dart';
import 'package:final_menu/requestpage/request_page.dart';
import 'package:flutter/material.dart';

class HomePage1 extends StatelessWidget {
  final String pickupLatitude = '27.6508';
  final String pickupLongitude = '84.5142';
  final String deliveryLatitude = '27.3383';
  final String deliveryLongitude = '85.5020';
  @override
  Widget build(BuildContext context) {
    final String? message = ModalRoute.of(context)?.settings.arguments as String?;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                String url = 'https://www.openstreetmap.org/directions?engine=graphhopper_car&route=$pickupLatitude%2C$pickupLongitude%3B$deliveryLatitude%2C$deliveryLongitude';
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(url:url,),
                  ),
                );
              },
              child: Text('Show Map'),
            ),
            ElevatedButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=> SignInPage()));
            }, child: const Text('Sign-Out')),
            
            
            ElevatedButton(
              onPressed: () {
               
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DriverAuthPage(),
                  ),
                );
              },
              child: Text('Driver Signup Page'),
            ),

            ElevatedButton(
              onPressed: () {
               
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DriverAuthPage(),
                  ),
                );
              },
              child: Text('Driver-Register Page'),
            ),
          ],
        ),),
    );
  }
}