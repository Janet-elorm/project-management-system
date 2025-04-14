import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileSettings extends StatefulWidget {
  final String userName;
  final String email;
  final String phoneNumber;
  final String profilePictureUrl;
  final Function(String) onUpdateProfilePicture;
  final Function(String, String) onUpdateUserInfo;
  final VoidCallback onLogout;

  const ProfileSettings({
    Key? key,
    required this.userName,
    required this.email,
    required this.phoneNumber,
    required this.profilePictureUrl,
    required this.onUpdateProfilePicture,
    required this.onUpdateUserInfo,
    required this.onLogout,
  }) : super(key: key);

  @override
  _ProfileSettingsState createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.userName);
    emailController = TextEditingController(text: widget.email);
    phoneController = TextEditingController(text: widget.phoneNumber);
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      // Upload image to backend and update profile picture URL
      widget.onUpdateProfilePicture(pickedFile.path);
    }
  }

  void _saveChanges() {
    widget.onUpdateUserInfo(
      nameController.text,
      phoneController.text,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.4),
      body: Align(
        alignment: Alignment.centerRight,
        child: Container(
          width: 300,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Profile Settings",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!) as ImageProvider
                            : NetworkImage(widget.profilePictureUrl),
                        radius: 40,
                      ),
                      const CircleAvatar(
                        backgroundColor: Colors.blue,
                        radius: 12,
                        child: Icon(Icons.camera_alt, color: Colors.white, size: 14),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Full Name"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                readOnly: true,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Phone Number"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveChanges,
                child: const Text("Save Changes"),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: widget.onLogout,
                child: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
