import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference vehicleData =
      FirebaseFirestore.instance.collection('vehicleData');

  Future<void> addVehicleData({
    required String vehicleType,
    required String numberPlate,
    required String brand,
    required String color,
    required String bluebookPhotoUrl,
    required String licenseNumber,
    required String citizenshipFrontUrl,
    required String licenseFrontUrl,
    required String selfieWithCitizenshipUrl,
    required String selfieWithLicenseUrl,
    required String name,
    required String address,
    required String dob,
    required String email,
    required String phone,
  }) async {
    await vehicleData.add({
      'vehicleInfo': {
        'vehicleType': vehicleType,
        'numberPlate': numberPlate,
        'brand': brand,
        'color': color,
        'bluebookPhotoUrl': bluebookPhotoUrl,
      },
      'legalDocs': {
        'licenseNumber': licenseNumber,
        'citizenshipFrontUrl': citizenshipFrontUrl,
        'licenseFrontUrl': licenseFrontUrl,
        'selfieWithCitizenshipUrl': selfieWithCitizenshipUrl,
        'selfieWithLicenseUrl': selfieWithLicenseUrl,
      },
      'personalInfo': {
        'name': name,
        'address': address,
        'dob': dob,
        'email': email,
        'phone': phone,
      },
    }).then((value) {
      print('Vehicle Data Added');
    }).catchError((error) {
      print('Failed to add vehicle data: $error');
    });
  }
}
