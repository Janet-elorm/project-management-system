import 'package:capstone_flutter/api_service/auth_service.dart';
import 'package:capstone_flutter/api_service/task_manager_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Import for iOS style

class AddTaskDialog extends StatefulWidget {
  final String category;
  final Function onTaskAdded;
  final int projectId;

  AddTaskDialog({
    required this.category,
    required this.onTaskAdded,
    required this.projectId,
  });

  @override
  _AddTaskDialogState createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  String _priority = 'low';
  int? _currentUserId;
  bool _isLoading = false; // Track loading state

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    final user = await AuthService().getCurrentUser();
    if (user != null && mounted) {
      setState(() {
        _currentUserId = user['user_id'];
      });
    }
  }

  // Function to show a platform-adaptive dialog
  void _showDialog({required WidgetBuilder builder}) {
    showDialog(
      context: context,
      builder: (context) {
        return Theme.of(context).platform == TargetPlatform.iOS
            ? CupertinoPopupSurface( // iOS style
                child: builder(context),
              )
            : builder(context); // Default to AlertDialog for Android
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator()) // Show loading indicator
        : AlertDialog(
            backgroundColor: const Color.fromARGB(255, 255, 255, 255), // Set background color to white
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text("Add New Task", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
            content: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                      onChanged: (value) => _title = value,
                      validator: (value) => value!.isEmpty ? 'Enter a title' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                      onChanged: (value) => _description = value,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: "Priority",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                      value: _priority,
                      items: ['low', 'medium', 'high'].map((priority) {
                        return DropdownMenuItem(
                          value: priority,
                          child: Text(priority[0].toUpperCase() + priority.substring(1)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _priority = val!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Cancel", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (_currentUserId == null) {
                      _showDialog(
                        builder: (context) => AlertDialog(
                          title: Text("Login Required"),
                          content: Text("You need to Login/Signup first"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text("OK"),
                            ),
                          ],
                        ),
                      );
                      return;
                    }

                    setState(() {
                      _isLoading = true;
                    });

                    final taskData = {
                      'title': _title,
                      'description': _description,
                      'priority': _priority,
                      'category': widget.category,
                      'project_id': widget.projectId,
                      'due_date': DateTime.now().toIso8601String().split('T')[0],
                      'assigned_to': _currentUserId,
                    };

                    try {
                      await TaskManagerService().createTask(widget.projectId, taskData);
                      widget.onTaskAdded();
                      Navigator.of(context).pop();
                    } catch (error) {
                       _showDialog(
                        builder: (context) => AlertDialog(
                          title: Text("Error"),
                          content: Text("Failed to create task. Please try again."),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text("OK"),
                            ),
                          ],
                        ),
                      );
                    } finally {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  }
                },
                child: Text("Save", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ],
          );
  }
}

