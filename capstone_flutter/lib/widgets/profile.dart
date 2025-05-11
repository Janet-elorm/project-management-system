import 'dart:io';
import 'package:capstone_flutter/pages/dashboard.dart';
import 'package:capstone_flutter/pages/progressTracker.dart';
import 'package:capstone_flutter/pages/projects.dart';
import 'package:capstone_flutter/pages/taskManager.dart';
import 'package:capstone_flutter/widgets/mainLayout.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:capstone_flutter/api_service/auth_service.dart';

class ProfilePage extends StatefulWidget {
  final int projectId;
  const ProfilePage({Key? key, required this.projectId}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  File? _imageFile;
  String? _profileImageUrl;
  bool _isLoading = false;
  String selectedPage = "Profile";

  // User data
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _phone = '';
  String _bio = '';
  String _position = '';
  String _status = 'On duty';
  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);
    try {
      final userData = await _authService.getCurrentUser();
      if (userData != null) {
        setState(() {
          _firstName = userData['first_name'] ?? '';
          _lastName = userData['last_name'] ?? '';
          _email = userData['email'] ?? '';
          _phone = userData['phone_no'] ?? '';
          _profileImageUrl = userData['profile_picture'];
          _position = userData['position'] ?? 'Team Member';
          _username = userData['username'] ?? '';
          _bio = userData['bio'] ?? 'Discuss only during work hours';
        });
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  void handlePageSelected(String page) {
    if (page == "Dashboard") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    } else if (page == "Progress Tracker") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProgressTrackingPage(projectId: widget.projectId),
        ),
      );
    } else if (page == "Task Manager") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TaskManagerPage(projectId: widget.projectId),
        ),
      );
    } else if (page == "Projects") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProjectsPage(projectId: widget.projectId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      selectedPage: selectedPage,
      onPageSelected: handlePageSelected,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  // Left side profile photo & name
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 70,
                              backgroundImage: _imageFile != null
                                  ? FileImage(_imageFile!)
                                  : (_profileImageUrl != null
                                      ? NetworkImage(_profileImageUrl!)
                                      : const AssetImage('assets/default_profile.png')
                                          as ImageProvider),
                            ),
                            IconButton(
                              icon: const Icon(Icons.camera_alt, color: Colors.white),
                              style: IconButton.styleFrom(
                                backgroundColor: Color.fromARGB(255, 151, 167, 186),
                              ),
                              onPressed: _pickImage,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '$_firstName $_lastName',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _position,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.circle, size: 12, color: Colors.green),
                              const SizedBox(width: 6),
                              Text(
                                _status,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 40),

                  // Right side details
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bio & Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildInfoRow('Username', _username),
                          _buildInfoRow('Email', _email),
                          _buildInfoRow('Phone', _phone),
                          _buildInfoRow('About Me', _bio),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
