import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:image_picker/image_picker.dart'; // For opening native camera app
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _locationMessage = "Fetching location...";
  LatLng _currentLocation = LatLng(0, 0);
  GoogleMapController? _mapController;
  bool _showMap = false;
  double _accuracy = 100.0;
  double _stdDeviation = 1.0;
  String _lat = "N/A";
  String _lon = "N/A";
  bool _showManage = false; // New boolean to show or hide the form

  bool _showForm = false; // New boolean to show or hide the form
  String? _selectedCropStage;
  String? _selectedCropHealth;
  String? _selectedCropCover;
  String? _selectedsoilcondition;
  File? _capturedImage1;
  File? _capturedImage2;

  // Add TextEditingController for each TextField
  final TextEditingController _villageController = TextEditingController();
  final TextEditingController _fieldController = TextEditingController();
  final TextEditingController _cropTypeController = TextEditingController();
  final TextEditingController _cropSizeController = TextEditingController();
  final TextEditingController _cropStageController = TextEditingController();
  final TextEditingController _cropHealthController = TextEditingController();
  final TextEditingController _cropCoverController = TextEditingController();
  final TextEditingController _cropvariety = TextEditingController();
  final TextEditingController _dateofsowing = TextEditingController();
  final TextEditingController _othercropinfield = TextEditingController();
  final TextEditingController _anyotherremarks = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  void _exitApp(BuildContext context) {
    // This will close the app and go to the home screen.
    SystemNavigator.pop();
  }

  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.camera,
      Permission.storage,
    ].request();

    if (statuses[Permission.location]?.isGranted == true) {
      _fetchLocation();
    } else {
      setState(() {
        _locationMessage = "Location permission denied.";
      });
    }

    if (statuses[Permission.camera]?.isGranted != true) {
      setState(() {
        _locationMessage = "Camera permission denied.";
      });
    }

    if (statuses[Permission.storage]?.isGranted != true) {
      setState(() {
        _locationMessage = "Storage permission denied.";
      });
    }

    if (statuses.values.any((status) => status.isPermanentlyDenied)) {
      openAppSettings();
    }
  }

  double _calculateStdDeviation() {
    return Random().nextDouble() / 2;
  }

  Future<void> _fetchLocation() async {
    bool locationAccurate = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Please wait...'),
        content: Text(
            'GPS accuracy is being refined. Waiting for accuracy below 20m and standard deviation between 0 and 0.5.'),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );

    try {
      while (!locationAccurate) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        _accuracy = position.accuracy;
        _stdDeviation = _calculateStdDeviation();
        _lat = position.latitude.toString();
        _lon = position.longitude.toString();

        if (_accuracy < 20 && _stdDeviation > 0 && _stdDeviation < 0.5) {
          locationAccurate = true;
          _currentLocation = LatLng(position.latitude, position.longitude);
          _locationMessage =
              "Lat: ${position.latitude}, Long: ${position.longitude}";
          Navigator.of(context).pop();
        }

        setState(() {
          _locationMessage = "Accuracy: ${_accuracy.toStringAsFixed(4)} m, "
              "Std Dev: ${_stdDeviation.toStringAsFixed(2)}, "
              "Lat: $_lat, Long: $_lon";
        });

        await Future.delayed(Duration(seconds: 1));
      }
    } catch (e) {
      setState(() {
        _locationMessage = "Failed to fetch location: $e";
      });
      Navigator.of(context).pop();
    }
  }

  int _captureCount = 0; // To track the number of captures

  Future<void> _capturePhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        if (_captureCount == 0) {
          _capturedImage1 = File(pickedFile.path); // First image
          _captureCount++;
        } else if (_captureCount == 1) {
          _capturedImage2 = File(pickedFile.path); // Second image
          _captureCount++; // No more captures after second image
        }
      });
    } else {
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("No image selected."),
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 16),
            Text(
              "Fasal APK is built to serve the purpose of Fasal",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                "GPS fetching: $_locationMessage",
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                setState(() {
                  _showMap = !_showMap;
                });
              },
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                    ),
                    child: Image.asset(
                      'assets/map.png',
                      width: 40,
                      height: 40,
                    ),
                  ),
                  Text('Map'),
                ],
              ),
            ),

            _showMap
                ? Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: GoogleMap(
                      onMapCreated: (controller) => _mapController = controller,
                      initialCameraPosition: CameraPosition(
                        target: _currentLocation,
                        zoom: 14,
                      ),
                      markers: {
                        Marker(
                          markerId: MarkerId('currentLocation'),
                          position: _currentLocation,
                        ),
                      },
                    ),
                  )
                : SizedBox.shrink(),
            SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: _fetchLocation,
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/gps.png',
                        width: 50,
                        height: 50,
                      ),
                      Text('GPS'),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _accuracy < 20
                      ? _capturePhoto
                      : null, // Enable camera only if accuracy < 20m
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/camera.png',
                        width: 50,
                        height: 50,
                      ),
                      Text('Camera',
                          style: TextStyle(
                              color: _accuracy < 20
                                  ? Colors.red
                                  : Colors
                                      .grey)), // Disable text when camera is unavailable
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showForm = !_showForm; // Toggle form visibility
                    });
                  },
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/attribute.png',
                        width: 50,
                        height: 50,
                      ),
                      Text('Attribute'),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            _capturedImage1 != null
                ? Image.file(
                    _capturedImage1!,
                    width: 300,
                    height: 300,
                  )
                : Text("No image 1"),
            SizedBox(height: 20),
            _capturedImage2 != null
                ? Image.file(
                    _capturedImage2!,
                    width: 300,
                    height: 300,
                  )
                : Text("No image  2"),
            SizedBox(height: 40),

            // Conditionally show the form when the attribute is clicked
            _showForm
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Input fields with dropdown functionality
                        TextField(
                          controller: _villageController,
                          decoration: InputDecoration(
                            labelText: 'Village',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: _fieldController,
                          decoration: InputDecoration(
                            labelText: 'Field (yyyymmdd-nnn)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: _cropTypeController,
                          decoration: InputDecoration(
                            labelText: 'Type of Crop',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: _cropSizeController,
                          decoration: InputDecoration(
                            labelText: 'Size of Crop Field',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 16),

                        // Crop Stage Dropdown within Input Box
                        DropdownButtonFormField<String>(
                          value: _selectedCropStage,
                          decoration: InputDecoration(
                            labelText: 'Crop Growth Stage',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            'Transplanting',
                            'Sowing',
                            'Tilling',
                            'Vegetative',
                            'Flowering',
                            'Maturity',
                            'Others'
                          ].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCropStage = newValue;
                            });
                          },
                        ),
                        SizedBox(height: 16),

                        // Crop Health Condition Dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedCropHealth,
                          decoration: InputDecoration(
                            labelText: 'Crop Health Condition',
                            border: OutlineInputBorder(),
                          ),
                          items:
                              ['Good', 'Average', 'Poor'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCropHealth = newValue;
                            });
                          },
                        ),
                        SizedBox(height: 16),

                        // Crop Cover Ground Dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedCropCover,
                          decoration: InputDecoration(
                            labelText: 'Crop Cover On Ground',
                            border: OutlineInputBorder(),
                          ),
                          items: ['0-20%', '21-40%', '41-60%', '61-80%', '>80%']
                              .map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCropCover = newValue;
                            });
                          },
                        ),
                        SizedBox(height: 16),

                        TextField(
                          controller: _cropvariety,
                          decoration: InputDecoration(
                            labelText: 'Crop Variety:',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 16),

                        TextField(
                          controller: _dateofsowing,
                          decoration: InputDecoration(
                            labelText:
                                'Date Of Sowing/Exp. Date of Harvesting(DDMMYYYY):',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 16),

                        TextField(
                          controller: _othercropinfield,
                          decoration: InputDecoration(
                            labelText: 'Other Crop in Field',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 16),

                        DropdownButtonFormField<String>(
                          value: _selectedsoilcondition,
                          decoration: InputDecoration(
                            labelText: 'Soil Condition',
                            border: OutlineInputBorder(),
                          ),
                          items:
                              ['Flooded', 'Moist', 'Dry'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedsoilcondition = newValue;
                            });
                          },
                        ),
                        SizedBox(height: 16),

                        TextField(
                          controller: _anyotherremarks,
                          decoration: InputDecoration(
                            labelText: 'Any Other Remarks',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 16),
                      ],
                    ),
                  )
                : SizedBox.shrink(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    // Action for Save
                  },
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/save.png',
                        width: 50,
                        height: 50,
                      ),
                      Text('Save'),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showManage = !_showManage;
                    });
                  },
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/manage.png',
                        width: 50,
                        height: 50,
                      ),
                      Text('Manage'),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Action for Send
                  },
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/send.png',
                        width: 50,
                        height: 50,
                      ),
                      Text('Send'),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            _showManage
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Action for Send Later
                        },
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/sendlater.png',
                              width: 30,
                              height: 30,
                            ),
                            Text('Send Later'),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Action for View Sent
                        },
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/viewsent.png',
                              width: 30,
                              height: 30,
                            ),
                            Text('View send'),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Action for View Sent
                        },
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/sen.png',
                              width: 30,
                              height: 30,
                            ),
                            Text('sent'),
                          ],
                        ),
                      ),
                    ],
                  )
                : SizedBox.shrink(),
            SizedBox(height: 30),

            Wrap(
              alignment: WrapAlignment.spaceEvenly,
              spacing: 20, // Adds spacing between items
              children: [
                GestureDetector(
                  onTap: () {
                    // Action for Send Later
                  },
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/refresh.png',
                        width: 50,
                        height: 50,
                      ),
                      Text('Refresh'),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _exitApp(context), // Exit action
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/exit.png',
                        width: 50,
                        height: 50,
                      ),
                      Text('Exit'),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Action for View Sent
                  },
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/profile.png',
                        width: 50,
                        height: 50,
                      ),
                      Text('Profile'),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Action for Help
                  },
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/help.png',
                        width: 50,
                        height: 50,
                      ),
                      Text('Help'),
                    ],
                  ),
                ),
              ],
            )
            // If _showM
          ],
        ),
      ),
    );
  }
}
