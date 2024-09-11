import 'package:final_menu/homepage.dart';
import 'package:flutter/material.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final TextEditingController _pickupLatController = TextEditingController();
  final TextEditingController _pickupLonController = TextEditingController();
  final TextEditingController _deliveryLatController = TextEditingController();
  final TextEditingController _deliveryLonController = TextEditingController();

  void _openMap() {
    final String pickupLat = _pickupLatController.text;
    final String pickupLon = _pickupLonController.text;
    final String deliveryLat = _deliveryLatController.text;
    final String deliveryLon = _deliveryLonController.text;

    final String mapUrl = 'https://www.openstreetmap.org/directions?engine=graphhopper_car&route=$pickupLat%2C$pickupLon%3B$deliveryLat%2C$deliveryLon#map=11/$pickupLat/$pickupLon';

    if (pickupLat.isNotEmpty && pickupLon.isNotEmpty && deliveryLat.isNotEmpty && deliveryLon.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(url: mapUrl),
        ),
      );
    } else {
      // Show an error message if any field is empty
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter all coordinates')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Map'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _pickupLatController,
              decoration: InputDecoration(
                labelText: 'Pickup Latitude',
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _pickupLonController,
              decoration: InputDecoration(
                labelText: 'Pickup Longitude',
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _deliveryLatController,
              decoration: InputDecoration(
                labelText: 'Delivery Latitude',
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _deliveryLonController,
              decoration: InputDecoration(
                labelText: 'Delivery Longitude',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _openMap,
              child: Text('View Map'),
            ),
          ],
        ),
      ),
    );
  }
}
