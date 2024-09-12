import 'dart:async';

import 'package:final_menu/Driver_initial-auth/driver_registration_page.dart';
import 'package:final_menu/homepage.dart';
import 'package:final_menu/login_screen/sign_up_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:card_loading/card_loading.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  String _selectedSortOption = 'Timestamp Newest First';
  final int _itemsPerPage = 10;
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  List<Map<String, dynamic>> _tripDataList = [];
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();
Timer? _removeOldTripsTimer;
  @override
  void initState() {
    super.initState();
    _fetchTrips();
    _removeOldTripsTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
    _removeOldTrips();
  });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _fetchTrips();
      }
    });
  }



  Future<void> _fetchTrips() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);

    Query query = FirebaseFirestore.instance
        .collection('trips')
        .orderBy(_getSortField(), descending: _getSortDescending())
        .limit(_itemsPerPage);

    if (_lastDocument != null) query = query.startAfterDocument(_lastDocument!);

    try {
      final querySnapshot = await query.get();
      if (querySnapshot.docs.isEmpty) {
        setState(() => _hasMore = false);
      } else {
        _lastDocument = querySnapshot.docs.last;
        var newTrips = querySnapshot.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          data['distance'] =
              double.tryParse(data['distance'] as String ?? '') ?? 0.0;
          data['fare'] = double.tryParse(data['fare'] as String ?? '') ?? 0.0;
          data['tripId'] = doc.id;
          return data;
        }).toList();

        newTrips.sort((a, b) => _sortTrips(a, b));

        if (mounted) setState(() => _tripDataList.addAll(newTrips));
      }
    } catch (e) {
      print("Error fetching trips: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshTrips() async {
    await _removeOldTrips();

    setState(() {
      _tripDataList.clear();
      _lastDocument = null;
      _hasMore = true;
    });
    await _fetchTrips();
  }

  Future<void> _removeOldTrips() async {
    final now = DateTime.now();
    final cutoff = now.subtract(const Duration(minutes: 30));

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('trips')
          .where('timestamp', isLessThan: cutoff)
          .get();

      final oldDocs = querySnapshot.docs;
      if (oldDocs.isNotEmpty) {
        for (final doc in oldDocs) {
          await doc.reference.delete();
        }
      }
    } catch (e) {
      print("Error removing old trips: $e");
    }
  }

  String _getSortField() => _selectedSortOption == 'Timestamp Newest First'
      ? 'timestamp'
      : 'timestamp';
  bool _getSortDescending() => _selectedSortOption == 'Timestamp Newest First';

  int _sortTrips(Map<String, dynamic> a, Map<String, dynamic> b) {
    switch (_selectedSortOption) {
      case 'Price Expensive First':
        return _compareByIntegerPart(b['fare'], a['fare']);
      case 'Price Cheap First':
        return _compareByIntegerPart(a['fare'], b['fare']);
      case 'Distance Largest First':
        return _compareByIntegerPart(b['distance'], a['distance']);
      case 'Distance Smallest First':
        return _compareByIntegerPart(a['distance'], b['distance']);
      default:
        return 0;
    }
  }

  int _compareByIntegerPart(double? num1, double? num2) {
    return (num1?.truncate() ?? 0).compareTo(num2?.truncate() ?? 0);
  }

  Future<void> _launchPhone(String phoneNumber, String tripId) async {
    try {
      DocumentSnapshot tripSnapshot = await FirebaseFirestore.instance
          .collection('trips')
          .doc(tripId)
          .get();

      if (tripSnapshot.exists) {
        final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
        if (await canLaunchUrl(launchUri)) {
          await _deleteTrip(tripId);
          await launchUrl(launchUri);
        } else {
          print('Could not launch $launchUri');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User Already Booked")),
          );
        }
      }
    } catch (e) {
      print("Error checking trip existence: $e");
    }
  }

  Future<void> _deleteTrip(String tripId) async {
    try {
      await FirebaseFirestore.instance.collection('trips').doc(tripId).delete();
      await _refreshTrips();
    } catch (e) {
      print("Error deleting trip: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trips'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                  _selectedSortOption = value;
                  _tripDataList.clear();
                  _lastDocument = null;
                  _hasMore = true;
                  _fetchTrips();
                });
            },
            itemBuilder: (context) => [
              'Timestamp Newest First',
              'Price Expensive First',
              'Price Cheap First',
              'Distance Largest First',
              'Distance Smallest First',
            ]
                .map((choice) =>
                    PopupMenuItem(value: choice, child: Text(choice)))
                .toList(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshTrips,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _tripDataList.length + (_hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= _tripDataList.length) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: CardLoading(
                    height: 150, borderRadius: BorderRadius.circular(15)),
              );
            }
            var tripData = _tripDataList[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Card(
                color: Colors.white.withOpacity(0.95),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                elevation: 5,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          tripData['username'] ?? 'No Username',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.phone),
                        onPressed: () {
                          final phoneNumber = tripData['phone'] ?? '';
                          final tripId = tripData['tripId'] ?? '';
                          if (phoneNumber.isNotEmpty && tripId.isNotEmpty) {
                            _launchPhone(phoneNumber, tripId);
                          }
                        },
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Pickup: ${tripData['pickupLocation'] ?? 'No pickup location'}',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w300)),
                      Text(
                          'Delivery: ${tripData['deliveryLocation'] ?? 'No delivery location'}',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w300)),
                      Text(
                          'Distance: ${tripData['distance']?.toStringAsFixed(2) ?? 'No distance'} km',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w300)),
                      Text(
                          'Fare: NPR ${tripData['fare']?.toStringAsFixed(2) ?? 'No fare'}',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w300)),
                      Text('Phone: ${tripData['phone'] ?? 'No phone'}',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w300)),
                      Text(
                          'Timestamp: ${tripData['timestamp']?.toDate() ?? 'No timestamp'}',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  isThreeLine: true,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _removeOldTripsTimer?.cancel(); 
    super.dispose();
  }
}

