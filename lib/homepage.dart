import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  final String url;

  HomePage({required this.url});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  InAppWebViewController? webView;
  bool _isLoading = true; // Flag to control the splash screen visibility

  @override
  void initState() {
    super.initState();
    _startDelay();
  }

  void _startDelay() async {
    // Delay for 1 seconds before hiding the loading indicator and showing the web page
    await Future.delayed(Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String> _getDistanceFromAPI(String location1, String location2) async {
    String apiUrl =
        'https://distance-api3.p.rapidapi.com/distance?location1=$location1&location2=$location2&unit=kilometers';
    String apiKey = 'cd3125ef15msh2caab8018e8198ap187972jsnb9ff3f522f8e';
    var response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'X-Rapidapi-Key': apiKey,
        'X-Rapidapi-Host': 'distance-api3.p.rapidapi.com',
      },
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      String distance = jsonResponse['distance'].toString();
      return distance;
    } else {
      return 'N/A';
    }
  }

  // Function to fetch user details from Firebase
  Future<Map<String, dynamic>> _getUserDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        // Safely return the data or an empty map if the data is null
        return userDoc.data() as Map<String, dynamic>? ?? {};
      }
    }
    // Return an empty map if the user is not found or data is not available
    return {};
  }

  // Function to calculate fare
  double _calculateFare(String distance) {
    double distanceInKm;

    try {
      distanceInKm = double.parse(distance);
    } catch (e) {
      // Handle the error if the string cannot be parsed as a double
      print('Error parsing distance: $e');
      return 0.0; // Return 0 or another default value in case of an error
    }

    double distanceInMeters = distanceInKm * 1000;
    double fare =
        (distanceInMeters / 100) * 2.2; // For every 100 meters, fare is 2.4
    return fare;
  }

  // Function to store data in Firebase Firestore
  Future<void> _storeDataInFirestore(Map<String, dynamic> data) async {
    String uniqueKey = FirebaseFirestore.instance
        .collection('trips')
        .doc()
        .id; // Generate unique key
    await FirebaseFirestore.instance
        .collection('trips')
        .doc(uniqueKey)
        .set(data);
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Display the web view only after the delay
            if (!_isLoading)
              InAppWebView(
                initialUrlRequest: URLRequest(
                  url: WebUri(
                      widget.url), // Use the map URL passed from HomePage
                ),
                initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                    javaScriptEnabled: true,
                    cacheEnabled: true,
                    useOnLoadResource: true,
                    mediaPlaybackRequiresUserGesture: false,
                  ),
                ),
                onWebViewCreated: (InAppWebViewController controller) {
                  webView = controller;
                },
                onLoadStop: (controller, url) async {
                  await controller.evaluateJavascript(source: """
        // Hide the "Map Viewer" text
    var mapViewerElement = document.querySelector('h1.d-flex.m-0.fw-semibold');
    if (mapViewerElement) mapViewerElement.style.display = 'none';

    // Remove the <a> element with class "btn btn-outline-primary geolink flex-grow-1" and id "history_tab"
    var historyLinkElement = document.querySelector('a.btn.btn-outline-primary.geolink.flex-grow-1#history_tab');
    if (historyLinkElement) historyLinkElement.remove();
    
    // Remove the element with classes "secondary d-flex gap-2 align-items-center"
    var secondaryElement = document.querySelector('.secondary.d-flex.gap-2.align-items-center');
    if (secondaryElement) secondaryElement.remove();
    
    // Remove the <a> element with class "btn btn-outline-primary geolink editlink" and id "editanchor"
    var editLinkElement = document.querySelector('a.btn.btn-outline-primary.geolink.editlink#editanchor');
    if (editLinkElement) editLinkElement.remove();

    // Other JavaScript manipulation here...
    result;
  """).then((result) {
                    if (result != null && result.isNotEmpty) {
                      String distanceAndTime = result;
                    }
                  });
                },
              ),
            // Show circular progress indicator while loading
            if (_isLoading)
              Center(
                child:
                    CircularProgressIndicator(), // Display progress indicator
              ),
            // Back button overlayed on the web view
            Positioned(
              bottom: 40,
              left: 5,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Icon(Icons.arrow_back),
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(10),
                ),
              ),
            ),
            // Show Location Button
            Positioned(
              bottom: 100,
              right: 5,
              child: ElevatedButton(
                onPressed: () async {
                  // Execute JavaScript to get the location details from the web page
                  String pickupLocation =
                      await webView?.evaluateJavascript(source: """
    document.getElementById('route_from').value
  """) ?? 'N/A';

                  String deliveryLocation =
                      await webView?.evaluateJavascript(source: """
    document.getElementById('route_to').value
  """) ?? 'N/A';

                  // Send the locations to the API to get the distance
                  if (pickupLocation != 'N/A' && deliveryLocation != 'N/A') {
                    String distance = await _getDistanceFromAPI(
                        pickupLocation, deliveryLocation);

                    // Calculate the fare
                    double fare = _calculateFare(distance);

                    // Show confirmation dialog with fare details
                    bool? confirmed = await showDialog<bool>(
                      context: context,
                      barrierDismissible:
                          false, // Prevent dismissal by tapping outside the dialog
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Confirm Booking'),
                          content: Text(
                            'Pickup: $pickupLocation\n'
                            'Delivery: $deliveryLocation\n'
                            'Distance: $distance km\n'
                            'Estimated Fare: NPR${fare.toStringAsFixed(2)}\n\n'
                            'Are you sure you want to book this ride?',
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop(
                                    false); // Return false to indicate cancellation
                              },
                            ),
                            TextButton(
                              child: Text('Confirm'),
                              onPressed: () {
                                Navigator.of(context).pop(
                                    true); // Return true to indicate confirmation
                              },
                            ),
                          ],
                        );
                      },
                    );

                    if (confirmed == true) {
                      // Proceed with the booking if confirmed
                      // Get user details
                      Map<String, dynamic> userDetails =
                          await _getUserDetails();
                      String username = userDetails['username'] ?? 'N/A';
                      String email = userDetails['email'] ?? 'N/A';
                      String phoneNumber = userDetails['phone_number'] ?? 'N/A';

                      // Prepare the data for storage
                      Map<String, dynamic> data = {
                        'username': username,
                        'email': email,
                        'phone': phoneNumber,
                        'pickupLocation': pickupLocation,
                        'deliveryLocation': deliveryLocation,
                        'distance': distance,
                        'fare': fare.toStringAsFixed(2),
                        'timestamp': FieldValue
                            .serverTimestamp(), // Add server timestamp
                      };

                      // Store the data in Firestore
                      await _storeDataInFirestore(data);

                      // Show the Snackbar with all the details, including the calculated fare
                      _showSnackbar(
                          'Username: $username\nEmail: $email\nPhone: $phoneNumber\nPickup: $pickupLocation\nDelivery: $deliveryLocation\nDistance: $distance km\nFare: NPR${fare.toStringAsFixed(2)}');
                    } else {
                      // Handle cancellation
                      _showSnackbar('Booking cancelled.');
                    }
                  } else {
                    _showSnackbar(
                        'Could not retrieve pickup or delivery location.');
                  }
                },
                child: Text('Book a Ride'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
