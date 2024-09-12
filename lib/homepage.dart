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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _startDelay();
  }

  void _startDelay() async {
    await Future.delayed(Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String> _getDistanceFromAPI(String location1, String location2) async {
    final apiUrl = 'https://distance-api3.p.rapidapi.com/distance?location1=$location1&location2=$location2&unit=kilometers';
    final apiKey = 'cd3125ef15msh2caab8018e8198ap187972jsnb9ff3f522f8e';
    
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'X-Rapidapi-Key': apiKey,
          'X-Rapidapi-Host': 'distance-api3.p.rapidapi.com',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['distance'].toString();
      }
    } catch (e) {
      print('Error fetching distance: $e');
    }
    return 'N/A';
  }

  Future<Map<String, dynamic>> _getUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        return userDoc.data() as Map<String, dynamic>? ?? {};
      } catch (e) {
        print('Error fetching user details: $e');
      }
    }
    return {};
  }

  double _calculateFare(String distance) {
    double distanceInKm;
    try {
      distanceInKm = double.parse(distance);
    } catch (e) {
      print('Error parsing distance: $e');
      return 0.0;
    }
    final distanceInMeters = distanceInKm * 1000;
    return (distanceInMeters / 100) * 2;
  }

  Future<void> _storeDataInFirestore(Map<String, dynamic> data) async {
    final uniqueKey = FirebaseFirestore.instance.collection('trips').doc().id;
    try {
      await FirebaseFirestore.instance.collection('trips').doc(uniqueKey).set(data);
    } catch (e) {
      print('Error storing data: $e');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), duration: Duration(seconds: 5)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Go back to the previous page
          },
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            if (!_isLoading)
              InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(widget.url)),
                initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                    javaScriptEnabled: true,
                    cacheEnabled: true,
                    useOnLoadResource: true,
                    mediaPlaybackRequiresUserGesture: false,
                  ),
                ),
                onWebViewCreated: (controller) {
                  webView = controller;
                },
                onLoadStop: (controller, url) async {
                  await controller.evaluateJavascript(source: """
                    var mapViewerElement = document.querySelector('h1.d-flex.m-0.fw-semibold');
                    if (mapViewerElement) mapViewerElement.style.display = 'none';

                    var historyLinkElement = document.querySelector('a.btn.btn-outline-primary.geolink.flex-grow-1#history_tab');
                    if (historyLinkElement) historyLinkElement.remove();
                    
                    var secondaryElement = document.querySelector('.secondary.d-flex.gap-2.align-items-center');
                    if (secondaryElement) secondaryElement.remove();
                    
                    var editLinkElement = document.querySelector('a.btn.btn-outline-primary.geolink.editlink#editanchor');
                    if (editLinkElement) editLinkElement.remove();

                    result;
                  """);
                },
              ),
            if (_isLoading)
              Center(child: CircularProgressIndicator()),
            Positioned(
              bottom: 100,
              right: 5,
              child: ElevatedButton(
                onPressed: () async {
                  final pickupLocation = await webView?.evaluateJavascript(source: "document.getElementById('route_from').value") ?? 'N/A';
                  final deliveryLocation = await webView?.evaluateJavascript(source: "document.getElementById('route_to').value") ?? 'N/A';

                  if (pickupLocation.isEmpty || deliveryLocation.isEmpty) {
                    _showSnackbar('Enter Proper Address');
                    return;
                  }

                  final distance = await _getDistanceFromAPI(pickupLocation, deliveryLocation);
                  final fare = _calculateFare(distance);

                  final confirmed = await showDialog<bool>(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => AlertDialog(
                      title: Text('Confirm Booking'),
                      content: Text(
                        'Pickup: $pickupLocation\n'
                        'Delivery: $deliveryLocation\n'
                        'Distance: $distance km\n'
                        'Estimated Fare: NPR${fare.toStringAsFixed(2)}\n\n'
                        'Are you sure you want to book this ride?',
                      ),
                      actions: <Widget>[
                        TextButton(child: Text('Cancel'), onPressed: () => Navigator.of(context).pop(false)),
                        TextButton(child: Text('Confirm'), onPressed: () => Navigator.of(context).pop(true)),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    final userDetails = await _getUserDetails();
                    final data = {
                      'username': userDetails['username'] ?? 'N/A',
                      'email': userDetails['email'] ?? 'N/A',
                      'phone': userDetails['phone_number'] ?? 'N/A',
                      'pickupLocation': pickupLocation,
                      'deliveryLocation': deliveryLocation,
                      'distance': distance,
                      'fare': fare.toStringAsFixed(2),
                      'timestamp': FieldValue.serverTimestamp(),
                    };

                    await _storeDataInFirestore(data);

                    _showSnackbar(
                        'Username: ${userDetails['username']}\nEmail: ${userDetails['email']}\nPhone: ${userDetails['phone_number']}\nPickup: $pickupLocation\nDelivery: $deliveryLocation\nDistance: $distance km\nFare: NPR${fare.toStringAsFixed(2)}');
                  } else {
                    _showSnackbar('Booking cancelled.');
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
