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
  
  // User data fields
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
    } catch (e) {
      print("Error loading profile data: $e");
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

  Future<void> _deleteImage() async {
    setState(() {
      _imageFile = null;
      _profileImageUrl = null;
    });
    // TODO: Implement API call to delete profile picture
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      // First upload image if changed
      if (_imageFile != null) {
        await _authService.uploadProfilePicture(_imageFile!);
      }
      
      // Then update profile data
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        actions: [
          if (_isEditing)
            TextButton(
              onPressed: _saveChanges,
              child: const Text('SAVE', style: TextStyle(color: Colors.white)),
            )
          else
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: 'Edit Profile',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Picture Section
                    Center(
                      child: Stack(
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
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.camera_alt, size: 20),
                                    color: Colors.white,
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                    ),
                                    onPressed: _pickImage,
                                  ),
                                  if (_profileImageUrl != null || _imageFile != null)
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 20),
                                      color: Colors.white,
                                      style: IconButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      onPressed: _deleteImage,
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (_isEditing) ...[
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton(
                          onPressed: _pickImage,
                          child: const Text('Change picture'),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),
                    
                    // Profile Name and Position
                    Center(
                      child: Column(
                        children: [
                          Text(
                            '$_firstName $_lastName',
                            style: const TextStyle(
                              fontSize: 24,
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
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                    const Divider(),

                    // Personal Information Section
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
                            onChanged: (value) => _firstName = value,
                            isEditing: _isEditing,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildEditableField(
                            label: 'Last Name',
                            value: _lastName,
                            onChanged: (value) => _lastName = value,
                            isEditing: _isEditing,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Email (non-editable)
                    _buildInfoRow(
                      icon: Icons.email,
                      label: 'Email address',
                      value: _email,
                    ),
                    const SizedBox(height: 16),

                    // Phone
                    _buildEditableField(
                      label: 'Phone',
                      value: _phone,
                      onChanged: (value) => _phone = value,
                      isEditing: _isEditing,
                      icon: Icons.phone,
                    ),
                    const SizedBox(height: 16),

                    // Username (non-editable)
                    _buildInfoRow(
                      icon: Icons.person,
                      label: 'Username',
                      value: _username,
                      subtitle: 'Available change in 25/04/2024',
                    ),
                    const SizedBox(height: 16),

                    // Status
                    _buildInfoRow(
                      icon: Icons.circle,
                      label: 'Status',
                      value: _status,
                      iconColor: Colors.green,
                    ),
                    const SizedBox(height: 24),
                    const Divider(),

                    // About Me Section
                    const Text(
                      'About me',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildEditableField(
                      label: '',
                      value: _bio,
                      onChanged: (value) => _bio = value,
                      isEditing: _isEditing,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    String? subtitle,
    Color? iconColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: iconColor ?? Colors.grey),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 28, top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(fontSize: 16),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditableField({
    required String label,
    required String value,
    required Function(String) onChanged,
    required bool isEditing,
    IconData? icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          if (icon != null)
            Row(
              children: [
                Icon(icon, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            )
          else
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          const SizedBox(height: 4),
        ],
        isEditing
            ? TextFormField(
                initialValue: value,
                onChanged: onChanged,
                maxLines: maxLines,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              )
            : Padding(
                padding: EdgeInsets.only(left: icon != null ? 28 : 0),
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
      ],
    );
  }
}