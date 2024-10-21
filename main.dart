import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'HOME/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ProfilePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ProfilePage extends StatelessWidget {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _organisationController = TextEditingController();

  Future<void> _showUUIDDialog(BuildContext context) async {
    String uuid = 'Fetching UUID...';

    // Fetch the UUID from the device
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      uuid = androidInfo.id; // Unique ID for Android device
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      uuid = iosInfo.identifierForVendor ?? 'Unknown'; // UUID for iOS
    }

    // Show the UUID in a dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Device UUID'),
          content: Text(uuid),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _exitApp(BuildContext context) {
    // This will close the app and go to the home screen.
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FASAL App'),
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Text(
                    'Your Profile',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _userIdController,
                  decoration: InputDecoration(
                    labelText: 'User ID',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Your Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _designationController,
                  decoration: InputDecoration(
                    labelText: 'Designation',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _mobileNumberController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Mobile Number',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _organisationController,
                  decoration: InputDecoration(
                    labelText: 'Organisation',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 30), // Add space before the icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.blue, // Background color for Save
                            shape: BoxShape.circle,
                          ),
                          padding:
                              EdgeInsets.all(16.0), // Space around the icon
                          child: Icon(
                            Icons.save,
                            size: 30,
                            color: Colors.white, // Icon color
                          ),
                        ),
                        SizedBox(height: 8),
                        Text('Save', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomeScreen()),
                        ); // Navigate to HomeScreen
                      },
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.green, // Background color for Home
                              shape: BoxShape.circle,
                            ),
                            padding:
                                EdgeInsets.all(16.0), // Space around the icon
                            child: Icon(
                              Icons.home,
                              size: 30,
                              color: Colors.white, // Icon color
                            ),
                          ),
                          SizedBox(height: 8),
                          Text('Home', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _exitApp(context), // Exit action
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.red, // Background color for Exit
                              shape: BoxShape.circle,
                            ),
                            padding:
                                EdgeInsets.all(12.0), // Space around the icon
                            child: Transform.rotate(
                              angle: 270 *
                                  (3.141592653589793 /
                                      180), // Convert degrees to radians
                              child: Icon(
                                Icons.exit_to_app,
                                size: 30,
                                color: Colors.white, // Icon color
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text('Exit', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30), // Add space before the next section
                Center(
                  // Center the Maintenance activity section
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Center vertically
                    crossAxisAlignment:
                        CrossAxisAlignment.center, // Center horizontally
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color:
                              Colors.orange, // Background color for Maintenance
                          shape: BoxShape.circle,
                        ),
                        padding: EdgeInsets.all(10.0), // Space around the icon
                        child: Icon(
                          Icons.settings, // Maintenance activity icon
                          size: 30,
                          color: Colors.white, // Icon color
                        ),
                      ),
                      SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Software ',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      SizedBox(height: 8), // Space between titles
                      Center(
                        child: Text(
                          'Maintenance Activity', // Replace with your remaining text
                          style: TextStyle(
                              fontSize: 16), // Customize style as needed
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30), // Add space before the next section
                Center(
                  // Center the Get UUID section
                  child: GestureDetector(
                    onTap: () {
                      _showUUIDDialog(context); // Show UUID in a popup
                    },
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.blueGrey, // Background color for UUID
                            shape: BoxShape.circle,
                          ),
                          padding:
                              EdgeInsets.all(16.0), // Space around the icon
                          child: Icon(
                            Icons.format_underlined_outlined, // UUID icon
                            size: 30,
                            color: Colors.white, // Icon color
                          ),
                        ),
                        SizedBox(height: 8),
                        Text('Get UUID', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
