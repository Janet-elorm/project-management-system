import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:capstone_flutter/api_service/auth_service.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  File? _imageFile;
  String? _profileImageUrl;
  bool _isLoading = false;
  bool _isEditing = false;

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

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      if (_imageFile != null) {
        await _authService.uploadProfilePicture(_imageFile!);
      }

      final updated = await _authService.updateProfile(
        firstName: _firstName,
        lastName: _lastName,
        phone: _phone,
        bio: _bio,
      );

      if (updated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        setState(() => _isEditing = false);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 220, 225, 232),
      appBar: AppBar(
        title: const Text("My Profile"),
        actions: [
          _isEditing
              ? TextButton(
                  onPressed: _saveChanges,
                  child: const Text('Save', style: TextStyle(color: Colors.white)),
                )
              : IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => setState(() => _isEditing = true),
                ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Container(
                width: 1000,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column (Profile + Name)
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                CircleAvatar(
                                  radius: 60,
                                  backgroundImage: _imageFile != null
                                      ? FileImage(_imageFile!)
                                      : (_profileImageUrl != null
                                          ? NetworkImage(_profileImageUrl!)
                                          : const AssetImage('assets/default_profile.png')
                                              as ImageProvider),
                                ),
                                if (_isEditing)
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.circle, size: 12, color: Colors.green),
                                const SizedBox(width: 6),
                                Text(
                                  _status,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 40),

                      // Right Column (Details)
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Personal Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // First Name & Last Name
                            Row(
                              children: [
                                Expanded(
                                  child: _buildEditableField(
                                    label: 'First Name',
                                    value: _firstName,
                                    onChanged: (v) => _firstName = v,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildEditableField(
                                    label: 'Last Name',
                                    value: _lastName,
                                    onChanged: (v) => _lastName = v,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Email (non-editable)
                            _buildInfo(label: 'Email', value: _email),
                            const SizedBox(height: 16),

                            // Phone
                            _buildEditableField(
                              label: 'Phone',
                              value: _phone,
                              onChanged: (v) => _phone = v,
                            ),
                            const SizedBox(height: 16),

                            // Username (non-editable)
                            _buildInfo(label: 'Username', value: _username),
                            const SizedBox(height: 16),

                            // Bio
                            _buildEditableField(
                              label: 'About me',
                              value: _bio,
                              onChanged: (v) => _bio = v,
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required String value,
    required Function(String) onChanged,
    int maxLines = 1,
  }) {
    return Column(
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
        _isEditing
            ? TextFormField(
                initialValue: value,
                onChanged: onChanged,
                maxLines: maxLines,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              )
            : Text(
                value,
                style: const TextStyle(fontSize: 16),
              ),
      ],
    );
  }

  Widget _buildInfo({
    required String label,
    required String value,
  }) {
    return Column(
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
    );
  }
}
