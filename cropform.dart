import 'package:flutter/material.dart';

class CropForm extends StatefulWidget {
  @override
  _CropFormState createState() => _CropFormState();
}

class _CropFormState extends State<CropForm> {
  // Form Controllers
  final _villageController = TextEditingController();
  final _fieldIdController = TextEditingController();
  final _cropTypeController = TextEditingController();
  final _cropSizeController = TextEditingController();

  // Dropdown values
  String? _selectedCropStage;
  String? _selectedCropHealth;
  String? _selectedCropCover;

  // Sample Dropdown Options
  final List<String> _cropStages = [
    'Seedling',
    'Vegetative',
    'Reproductive',
    'Harvest'
  ];
  final List<String> _cropHealthConditions = [
    'Healthy',
    'Diseased',
    'Pest Infected'
  ];
  final List<String> _cropCovers = ['Low', 'Medium', 'High'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crop Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: ListView(
            children: [
              // Village Input Field
              TextFormField(
                controller: _villageController,
                decoration: InputDecoration(labelText: 'Village'),
              ),

              // Field ID Input Field
              TextFormField(
                controller: _fieldIdController,
                decoration:
                    InputDecoration(labelText: 'Field ID (yyyymmdd-nnn)'),
              ),

              // Crop Type Input Field
              TextFormField(
                controller: _cropTypeController,
                decoration: InputDecoration(labelText: 'Type of Crop'),
              ),

              // Crop Size Input Field
              TextFormField(
                controller: _cropSizeController,
                decoration: InputDecoration(
                    labelText: 'Size of Crop Field (acres/hectares)'),
              ),

              // Dropdown for Crop Stage
              DropdownButtonFormField<String>(
                value: _selectedCropStage,
                decoration: InputDecoration(labelText: 'Crop Stage'),
                items: _cropStages.map((stage) {
                  return DropdownMenuItem<String>(
                    value: stage,
                    child: Text(stage),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCropStage = value;
                  });
                },
              ),

              // Dropdown for Crop Health Condition
              DropdownButtonFormField<String>(
                value: _selectedCropHealth,
                decoration: InputDecoration(labelText: 'Crop Health Condition'),
                items: _cropHealthConditions.map((health) {
                  return DropdownMenuItem<String>(
                    value: health,
                    child: Text(health),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCropHealth = value;
                  });
                },
              ),

              // Dropdown for Crop Cover Ground
              DropdownButtonFormField<String>(
                value: _selectedCropCover,
                decoration: InputDecoration(labelText: 'Crop Cover Ground'),
                items: _cropCovers.map((cover) {
                  return DropdownMenuItem<String>(
                    value: cover,
                    child: Text(cover),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCropCover = value;
                  });
                },
              ),

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Handle form submission
                  print('Form Submitted');
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: CropForm(),
  ));
}
