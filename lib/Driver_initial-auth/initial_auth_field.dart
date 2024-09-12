import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_menu/Driver_HomePages/first_land_page_after_registration.dart';
import 'package:final_menu/Driver_initial-auth/driver_registration_page.dart';
import 'package:final_menu/homepage.dart';
import 'package:final_menu/login_screen/sign_in_page.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DriverAuthPage extends StatefulWidget {
  @override
  _DriverAuthPageState createState() => _DriverAuthPageState();
}

class _DriverAuthPageState extends State<DriverAuthPage> {
  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  DateTime? _selectedDateOfBirth;
  final _picker = ImagePicker();
  String _selectedVehicleType = 'Tuk Tuk'; // Default value for dropdown

  final _numberPlateController = TextEditingController();
  final _brandController = TextEditingController();
  final _colorController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _dobController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  File? _bluebookPhoto;
  File? _citizenshipFrontPhoto;
  File? _licenseFrontPhoto;
  File? _selfieWithCitizenshipPhoto;
  File? _selfieWithLicensePhoto;

  String? _bluebookPhotoUrl;
  String? _citizenshipFrontUrl;
  String? _licenseFrontUrl;
  String? _selfieWithCitizenshipUrl;
  String? _selfieWithLicenseUrl;

  int _activeStep = 0; // Manage active step
  bool _termsAccepted = false; // Track terms acceptance

  bool _validateFields() {
    final email = _emailController.text;
    final phoneNumber = _phoneController.text.replaceAll('+977 ', '');

    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    final phoneNumberRegex = RegExp(r'^\d{10}$'); // 10 digits

    if (_nameController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _dobController.text.isEmpty ||
        email.isEmpty ||
        phoneNumber.isEmpty ||
        !emailRegex.hasMatch(email) ||
        !phoneNumberRegex.hasMatch(phoneNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Either you left some field or some entered format is incorrect',
          ),
        ),
      );
      return false;
    }

    return true;
  }

  Future<void> _pickImage(String imageType) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        switch (imageType) {
          case 'bluebook':
            _bluebookPhoto = File(pickedFile.path);
            break;
          case 'citizenshipFront':
            _citizenshipFrontPhoto = File(pickedFile.path);
            break;
          case 'licenseFront':
            _licenseFrontPhoto = File(pickedFile.path);
            break;
          case 'selfieWithCitizenship':
            _selfieWithCitizenshipPhoto = File(pickedFile.path);
            break;
          case 'selfieWithLicense':
            _selfieWithLicensePhoto = File(pickedFile.path);
            break;
        }
      });
    }
  }

  Future<File?> _compressImage(File imageFile) async {
    final img.Image? image = img.decodeImage(await imageFile.readAsBytes());
    if (image == null) return null;

    final img.Image resized =
        img.copyResize(image, width: 800); // Adjust size as needed
    final compressedFile = File(imageFile.path)
      ..writeAsBytesSync(
          img.encodeJpg(resized, quality: 85)); // Adjust quality as needed

    return compressedFile;
  }

  Future<String?> _uploadImage(
      File imageFile, String imageType, String userId) async {
    try {
      final compressedImageFile = await _compressImage(imageFile);
      final storageRef = FirebaseStorage.instance.ref().child(
          'images/$userId/$imageType/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = storageRef.putFile(compressedImageFile!);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _submitForm() async {
    if (_bluebookPhoto == null ||
        _citizenshipFrontPhoto == null ||
        _licenseFrontPhoto == null ||
        _selfieWithCitizenshipPhoto == null ||
        _selfieWithLicensePhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload all required photos.')),
      );
      return;
    }

    try {
      String userId = _emailController.text; // Unique identifier (email)

      // Upload images and get URLs
      if (_bluebookPhoto != null) {
        _bluebookPhotoUrl =
            await _uploadImage(_bluebookPhoto!, 'bluebook', userId);
      }
      if (_citizenshipFrontPhoto != null) {
        _citizenshipFrontUrl = await _uploadImage(
            _citizenshipFrontPhoto!, 'citizenshipFront', userId);
      }
      if (_licenseFrontPhoto != null) {
        _licenseFrontUrl =
            await _uploadImage(_licenseFrontPhoto!, 'licenseFront', userId);
      }
      if (_selfieWithCitizenshipPhoto != null) {
        _selfieWithCitizenshipUrl = await _uploadImage(
            _selfieWithCitizenshipPhoto!, 'selfieWithCitizenship', userId);
      }
      if (_selfieWithLicensePhoto != null) {
        _selfieWithLicenseUrl = await _uploadImage(
            _selfieWithLicensePhoto!, 'selfieWithLicense', userId);
      }

      // Save data to Firestore
      final vehicleData = FirebaseFirestore.instance.collection('vehicleData');
      await vehicleData.doc(userId).set({
        'vehicleType': _selectedVehicleType,
        'numberPlate': _numberPlateController.text,
        'brand': _brandController.text,
        'color': _colorController.text,
        'bluebookPhotoUrl': _bluebookPhotoUrl ?? '',
        'licenseNumber': _licenseNumberController.text,
        'citizenshipFrontUrl': _citizenshipFrontUrl ?? '',
        'licenseFrontUrl': _licenseFrontUrl ?? '',
        'selfieWithCitizenshipUrl': _selfieWithCitizenshipUrl ?? '',
        'selfieWithLicenseUrl': _selfieWithLicenseUrl ?? '',
        'name': _nameController.text,
        'address': _addressController.text,
        'dob': _dobController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
      });

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successful Registration.')),
      );

      // Wait for 1 second before navigating to the next page
      await Future.delayed(const Duration(seconds: 1));

      // Navigate to HI.dart
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
            builder: (context) =>
                DriverHomePage()), // Replace HI with the correct page name
      );
    } catch (e) {
      print('Error submitting form: $e');
    }
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = pickedDate;
        // Format the date and update the controller
        _dobController.text =
            '${_selectedDateOfBirth!.toLocal()}'.split(' ')[0];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // Check if the user is already logged in
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedEmail = prefs.getString('driverEmail');

    if (savedEmail != null) {
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DriverHomePage()),
      );
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Information Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DriverRegistrationPage()));
              },
              child: const Text(
                ' Already? Sign In Here (Driver Mode)',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor: Color.fromARGB(255, 101, 12, 185)),
              ),
            ),


SizedBox(
  height: 5,
),
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SignInPage()));
              },
              child: const Text(
                'Passenger Mode',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor: Color.fromARGB(255, 101, 12, 185)),
              ),
            ),



            EasyStepper(
              activeStep: _activeStep,
              onStepReached: (index) {
                setState(() {
                  if (_activeStep == 0 && !_termsAccepted && index > 0) {
                    // Prevent navigation if terms are not accepted
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Please accept the terms and conditions.')),
                    );
                  } else {
                    _activeStep = index;
                  }
                });
              },
              steps: const [
                EasyStep(
                  title: 'Terms & Conditions',
                  icon: Icon(Icons.assignment),
                ),
                EasyStep(
                  title: 'Vehicle Info',
                  icon: Icon(Icons.car_rental_rounded),
                ),
                EasyStep(
                  title: 'Documents',
                  icon: Icon(Icons.attach_file_outlined),
                ),
                EasyStep(
                  title: 'Personal Info',
                  icon: Icon(Icons.person),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (_activeStep == 0) ...[
                      // Terms & Conditions Step
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Terms and Conditions',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 10),
                            SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: SizedBox(
                                height: 400, // Set height for scrollable area
                                child: ListView(
                                  children: [
                                    Text(
                                      _termsAndConditionsText,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Checkbox(
                                  value: _termsAccepted,
                                  onChanged: (bool? newValue) {
                                    setState(() {
                                      _termsAccepted = newValue ?? false;
                                    });
                                  },
                                ),
                                const Text('I accept the terms and conditions'),
                              ],
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                if (_termsAccepted) {
                                  setState(() {
                                    _activeStep =
                                        1; // Move to Vehicle Info step
                                  });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Please accept the terms and conditions.')),
                                  );
                                }
                              },
                              child: const Text('Accept and Proceed'),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (_activeStep == 1) ...[
                      // Vehicle Info Step
                      DropdownButton<String>(
                        value: _selectedVehicleType,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedVehicleType = newValue!;
                          });
                        },
                        items: <String>['Tuk Tuk']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      TextField(
                        controller: _numberPlateController,
                        decoration: const InputDecoration(
                          labelText: 'Number Plate',
                        ),
                      ),

                      TextField(
                        controller: _brandController,
                        decoration: const InputDecoration(
                          labelText: 'Brand',
                        ),
                      ),

                      TextField(
                        controller: _colorController,
                        decoration: const InputDecoration(
                          labelText: 'Color',
                        ),
                      ),

                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _activeStep = 2; // Move to Documents step
                          });
                        },
                        child: const Text('Next'),
                      ),
                    ],
                    if (_activeStep == 2) ...[
                      // Documents Step
                      ElevatedButton(
                        onPressed: () => _pickImage('bluebook'),
                        child: const Text('Upload Bluebook Photo'),
                      ),
                      if (_bluebookPhoto != null) ...[
                        Image.file(_bluebookPhoto!),
                      ],
                      ElevatedButton(
                        onPressed: () => _pickImage('citizenshipFront'),
                        child: const Text('Upload Citizenship Front Photo'),
                      ),
                      if (_citizenshipFrontPhoto != null) ...[
                        Image.file(_citizenshipFrontPhoto!),
                      ],
                      ElevatedButton(
                        onPressed: () => _pickImage('licenseFront'),
                        child: const Text('Upload License Front Photo'),
                      ),
                      if (_licenseFrontPhoto != null) ...[
                        Image.file(_licenseFrontPhoto!),
                      ],
                      ElevatedButton(
                        onPressed: () => _pickImage('selfieWithCitizenship'),
                        child:
                            const Text('Upload Selfie with Citizenship Photo'),
                      ),
                      if (_selfieWithCitizenshipPhoto != null) ...[
                        Image.file(_selfieWithCitizenshipPhoto!),
                      ],
                      ElevatedButton(
                        onPressed: () => _pickImage('selfieWithLicense'),
                        child: const Text('Upload Selfie with License Photo'),
                      ),
                      if (_selfieWithLicensePhoto != null) ...[
                        Image.file(_selfieWithLicensePhoto!),
                      ],
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _activeStep =
                                3; // Move to Personal Information step
                          });
                        },
                        child: const Text('Next'),
                      ),
                    ],
                    if (_activeStep == 3) ...[
                      // Personal Information Step
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                        ),
                      ),

                      TextField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Address',
                        ),
                      ),

                      TextField(
                        controller: _dobController,
                        decoration: const InputDecoration(
                          labelText: 'Date of Birth',
                        ),
                        readOnly: true,
                        onTap: _selectDateOfBirth,
                      ),

                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          final emailRegex =
                              RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
                          if (value == null || value.isEmpty) {
                            return 'Please enter an email address.';
                          } else if (!emailRegex.hasMatch(value)) {
                            return 'Please enter a valid email address.';
                          }
                          return null; // Return null if validation is successful
                        },
                      ),

                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number (+977)',
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          final phoneNumber =
                              value?.replaceAll('+977 ', '') ?? '';
                          final phoneNumberRegex = RegExp(r'^\d{10}$');
                          if (!phoneNumberRegex.hasMatch(phoneNumber)) {
                            return 'Phone number must be 10 digits excluding +977.';
                          }
                          return null; // Return null if validation is successful
                        },
                      ),

                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          if (_validateFields()) {
                            _submitForm(); // Proceed to submit the form
                          }
                        },
                        child: const Text('Submit'),
                      )
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _termsAndConditionsText {
    return '''
    Terms and Conditions...

    1. Introduction
     Welcome to our service. By accessing or using our service, you agree to be bound by these terms and conditions. Please read them carefully.

     2. Changes to Terms
     We may update these terms from time to time. The updated version will be effective when we post it.

     3. User Responsibilities
     You agree to provide accurate information and to keep your account secure. You are responsible for all activities that occur under your account.

     4. Use of Service
     You agree to use our service only for lawful purposes and in accordance with our guidelines. You are prohibited from engaging in any activity that disrupts or interferes with our service.

     5. Privacy
     We are committed to protecting your privacy. Our privacy policy outlines how we collect, use, and share your information.

     6. Intellectual Property
     All content and materials on our service are owned by us or our licensors. You may not use or reproduce any content without our permission.

     7. Limitation of Liability
     We are not liable for any indirect, incidental, or consequential damages arising from your use of our service.

     8. Governing Law
     These terms are governed by the laws of the jurisdiction in which we operate. Any disputes will be resolved in the courts of that jurisdiction.

     9. Contact Us
     If you have any questions about these terms, please contact us at support@example.com.

      10. Governing Law & Jurisdiction
    These Terms will be governed by and interpreted in accordance with the laws of the State of [Your State], and you submit to the non-exclusive jurisdiction of the state and federal courts located in [Your State] for the resolution of any disputes.
    ''';
  }
}
