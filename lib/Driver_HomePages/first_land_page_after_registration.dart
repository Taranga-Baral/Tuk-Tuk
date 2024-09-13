

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:card_loading/card_loading.dart';
import 'package:url_launcher/url_launcher.dart';

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
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _fetchTrips();
      }
    });
  }

  // Fetch trips from Firestore
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

  // Launch phone number
  Future<void> _launchPhoneNumber(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      print('Could not launch $launchUri');
    }
  }

  // Geocode address to latitude and longitude
  Future<Map<String, double>> _geocodeAddress(String address) async {
    final response = await http.get(Uri.parse(
      'https://nominatim.openstreetmap.org/search?format=json&q=${Uri.encodeComponent(address)}'
    ));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        return {
          'latitude': double.parse(data[0]['lat']),
          'longitude': double.parse(data[0]['lon']),
        };
      }
    }
    throw Exception('Failed to geocode address');
  }

  // Launch OpenStreetMap with directions
  Future<void> _launchOpenStreetMapWithDirections(String tripId) async {
    try {
      DocumentSnapshot tripSnapshot = await FirebaseFirestore.instance
          .collection('trips')
          .doc(tripId)
          .get();

      if (tripSnapshot.exists) {
        final data = tripSnapshot.data() as Map<String, dynamic>;
        final pickupLocation = data['pickupLocation'] as String;
        final deliveryLocation = data['deliveryLocation'] as String;

        // Try to parse as coordinates
        final pickupCoords = _parseCoordinates(pickupLocation);
        final deliveryCoords = _parseCoordinates(deliveryLocation);

        double pickupLatitude;
        double pickupLongitude;
        double deliveryLatitude;
        double deliveryLongitude;

        if (pickupCoords != null) {
          pickupLatitude = pickupCoords['latitude']!;
          pickupLongitude = pickupCoords['longitude']!;
        } else {
          final pickupData = await _geocodeAddress(pickupLocation);
          pickupLatitude = pickupData['latitude']!;
          pickupLongitude = pickupData['longitude']!;
        }

        if (deliveryCoords != null) {
          deliveryLatitude = deliveryCoords['latitude']!;
          deliveryLongitude = deliveryCoords['longitude']!;
        } else {
          final deliveryData = await _geocodeAddress(deliveryLocation);
          deliveryLatitude = deliveryData['latitude']!;
          deliveryLongitude = deliveryData['longitude']!;
        }

        final String openStreetMapUrl =
            'https://www.openstreetmap.org/directions?engine=graphhopper_car&route=$pickupLatitude%2C$pickupLongitude%3B$deliveryLatitude%2C$deliveryLongitude';

        final Uri launchUri = Uri.parse(openStreetMapUrl);

        if (await canLaunchUrl(launchUri)) {
          await launchUrl(launchUri);
        } else {
          print('Could not launch $launchUri');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Trip details not found")),
          );
        }
      }
    } catch (e) {
      print("Error fetching trip details: $e");
    }
  }

  // Helper function to parse coordinates from string
  Map<String, double>? _parseCoordinates(String location) {
    final parts = location.split(',');
    if (parts.length == 2) {
      final latitude = double.tryParse(parts[0]);
      final longitude = double.tryParse(parts[1]);
      if (latitude != null && longitude != null) {
        return {'latitude': latitude, 'longitude': longitude};
      }
    }
    return null;
  }

  // Refresh trip list
  Future<void> _refreshTrips() async {
    await _removeOldTrips();

    setState(() {
      _tripDataList.clear();
      _lastDocument = null;
      _hasMore = true;
    });
    await _fetchTrips();
  }

  // Remove trips older than 30 minutes
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

  // Delete trip with confirmation
  Future<void> _deleteTripWithConfirmation(String tripId) async {
    try {
      DocumentSnapshot tripSnapshot = await FirebaseFirestore.instance
          .collection('trips')
          .doc(tripId)
          .get();

      if (tripSnapshot.exists) {
        // Show a confirmation dialog before deleting the trip
        bool? confirmed = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confirm Trip?'),
              content: Text('Are you sure you want to select this trip'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); 
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); 
                  },
                  child: Text('Confirm'),
                ),
              ],
            );
          },
        );

        if (confirmed == true) {
          await _deleteTrip(tripId);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Trip deleted successfully")),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Trip not found")),
          );
        }
      }
    } catch (e) {
      print("Error checking trip existence: $e");
    }
  }

  // Delete trip from Firestore
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
                        icon: const Icon(Icons.bookmark),
                        onPressed: () {
                          final phoneNumber = tripData['phone'] ?? '';
                          final tripId = tripData['tripId'] ?? '';
                          if (phoneNumber.isNotEmpty && tripId.isNotEmpty) {
                            _deleteTripWithConfirmation(tripId);
                          }
                        },
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      IconButton(
                        icon: const Icon(Icons.phone),
                        onPressed: () {
                          final phoneNumber = tripData['phone'] ?? '';
                          _launchPhoneNumber(phoneNumber);
                        },
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      IconButton(
                        icon: const Icon(Icons.location_history),
                        onPressed: () {
                          final tripId = tripData['tripId'] ?? '';
                          _launchOpenStreetMapWithDirections(tripId);
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
