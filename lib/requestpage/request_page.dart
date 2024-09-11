import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RequestPage extends StatefulWidget {
  const RequestPage({super.key});

  @override
  _RequestPageState createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Requests'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final requests = snapshot.data!.docs;

          if (requests.isEmpty) {
            return const Center(child: Text('No pending requests'));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              var request = requests[index].data() as Map<String, dynamic>;

              return Card(
                child: ListTile(
                  title: Text('Driver: ${request['name']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Phone: ${request['phone']}'),
                      Text('Number Plate: ${request['numberPlate']}'),
                      Text('Vehicle Type: ${request['vehicleType']}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check),
                        color: Colors.green,
                        onPressed: () => _acceptRequest(request),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        color: Colors.red,
                        onPressed: () => _rejectRequest(request),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Accept the driver's request and remove the trip from the trips collection
  Future<void> _acceptRequest(Map<String, dynamic> request) async {
    try {
      await FirebaseFirestore.instance
          .collection('trips')
          .doc(request['tripId'])
          .delete(); // Remove the trip from the trips collection

      await FirebaseFirestore.instance
          .collection('requests')
          .doc(request['requestId'])
          .update({'status': 'accepted'}); // Update request status

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request from ${request['name']} accepted.')),
      );
    } catch (e) {
      print('Error accepting request: $e');
    }
  }

  // Reject the driver's request
  Future<void> _rejectRequest(Map<String, dynamic> request) async {
    try {
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(request['requestId'])
          .update({'status': 'rejected'}); // Update request status

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request from ${request['name']} rejected.')),
      );
    } catch (e) {
      print('Error rejecting request: $e');
    }
  }
}
