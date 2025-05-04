import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:thingsboard_app/core/context/tb_context.dart';

import '../../constants/app_constants.dart';

class AddDevicePage extends StatefulWidget {

  AddDevicePage({
    required this.token,
    required this.owner,
    required this.tbContext,
    this.name,
    this.label
  });
  late final String token;
  late final String owner;
  late final TbContext tbContext;
  String? name;
  String? label;

  @override
  State<AddDevicePage> createState() => _AddDevicePageState();
}

class _AddDevicePageState extends State<AddDevicePage> {
  final TextEditingController labelController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController deviceProfileController = TextEditingController();
  late final TextEditingController ownerController;
  final _formKey = GlobalKey<FormState>();

  Widget customTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    bool readOnly = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }

  Widget customTextField2({
    required TextEditingController controller,
    required String label,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        absorbing: onTap != null,
        child: TextField(
          controller: controller,
          readOnly: readOnly,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            suffixIcon: suffixIcon,
          ),
        ),
      ),
    );
  }

  final Dio _dio = Dio();
  List<dynamic> deviceProfilesName = [];
  Future<void> fetchDeviceProfiles() async {
    try {
      deviceProfilesName = [];
      final response = await _dio.get(
        '${ThingsboardAppConstants.thingsBoardApiEndpoint}/api/deviceProfile/names',
        queryParameters: {
          'activeOnly': false,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${widget.token}',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        response.data.forEach((e){
          deviceProfilesName.add(e['name']);
        });
        if(deviceProfilesName.isNotEmpty){
          deviceProfileController.text = deviceProfilesName.first;
        }
        setState(() {});
        print('Device profiles fetched: $deviceProfilesName');
      } else {
        print('Failed to load device profiles. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching device profiles: $e');
    }
  }

  void _openDeviceProfilePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ListView.builder(
          itemCount: deviceProfilesName.length,
          itemBuilder: (context, index) {
            final profile = deviceProfilesName[index];
            return ListTile(
              title: Text(profile),
              onTap: () {
                setState(() {
                  deviceProfileController.text = profile;
                });
                Navigator.pop(context); // Close bottom sheet
              },
            );
          },
        );
      },
    );
  }

  Future<void> addDevice({
    required String name,
    required String label,
    required String type,
}) async {
    try {
      final response = await _dio.post(
        '${ThingsboardAppConstants.thingsBoardApiEndpoint}/api/device-with-credentials',
        data: {
          'device': {
            'name' : name,
            'label' : label,
            'type' : type
          },
          'credentials': {
            'credentialsType': 'ACCESS_TOKEN',
            'credentialsId': generateRandomString(20, widget.token)
          }
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${widget.token}',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        widget.tbContext.init();
        widget.tbContext.showSuccessNotification('Your device added successfully');
      } else {
        print('Failed to load device profiles. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      widget.tbContext.showErrorNotification('Device with such name already exists!');
      print('Error fetching device profiles: $e');
    }
  }

  String generateRandomString(int length,String chars) {
    final rand = Random();
    return List.generate(length, (index) => chars[rand.nextInt(chars.length)]).join();
  }

  @override
  void initState() {
    fetchDeviceProfiles();
    ownerController = TextEditingController(text: widget.owner);
    if(widget.name != null){
      nameController.text = widget.name!;
    }
    if(widget.label != null){
      labelController.text = widget.label!;
    }
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        title: const Text('Add Device', style: TextStyle(color: Colors.black)),
        leading: const BackButton(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              const Text(
                'Device Details',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              customTextField(
                controller: nameController,
                label: 'Name',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              customTextField(
                controller: labelController,
                label: 'Label',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Label is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
        
              deviceProfilesName.isNotEmpty ?
              customTextField2(controller: deviceProfileController, label: 'Device Profile',onTap: () {
                _openDeviceProfilePicker();
              },readOnly: false,suffixIcon: const Icon(Icons.keyboard_arrow_down_outlined))
                  : customTextField(
                  controller: deviceProfileController,
                  label: 'Device Profile',
                  readOnly: false,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Device Profile is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
        
              customTextField(controller: ownerController, label: 'Owner',readOnly: true),
        
              const SizedBox(height: 30),
        
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    addDevice(name: nameController.text, label: labelController.text, type: deviceProfileController.text);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThingsboardAppConstants.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  minimumSize: const Size(double.infinity, 55),
                  elevation: 5,
                  shadowColor: ThingsboardAppConstants.primaryColor,
                ),
                child: const Text(
                  'Add',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 15),
        
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: ThingsboardAppConstants.primaryColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
