import 'package:capstone_flutter/api_service/auth_service.dart';
import 'package:capstone_flutter/api_service/task_manager_service.dart';
import 'package:flutter/material.dart';

class AddTaskDialog extends StatefulWidget {
  final String category; // pass "to-do", "in-progress", or "completed"
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

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  int? _currentUserId;

  Future<void> _fetchCurrentUser() async {
    final user = await AuthService().getCurrentUser();
    if (user != null && mounted) {
      setState(() {
        _currentUserId = user['user_id'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title:
          Text("Add New Task", style: TextStyle(fontWeight: FontWeight.bold)),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => _title = value,
                validator: (value) => value!.isEmpty ? 'Enter a title' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => _description = value,
                maxLines: 3,
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Priority",
                  border: OutlineInputBorder(),
                ),
                value: _priority,
                items: ['low', 'medium', 'high'].map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child:
                        Text(priority[0].toUpperCase() + priority.substring(1)),
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
          child: Text("Cancel", style: TextStyle(color: Colors.grey)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            child: Text("Save", style: TextStyle(color: Colors.white)),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                if (_currentUserId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("You need to Login/Signup first")),
                  );
                  return;
                }

                final taskData = {
                  'title': _title,
                  'description': _description,
                  'priority': _priority,
                  'category': widget.category,
                  'project_id': widget.projectId,
                  'due_date': DateTime.now().toIso8601String().split('T')[0],
                  'assigned_to': _currentUserId, // ✅ now dynamic!
                };

                await TaskManagerService().createTask(widget.projectId, taskData);
                widget.onTaskAdded();
                Navigator.of(context).pop();
              }
            }),
      ],
    );
  }
}
