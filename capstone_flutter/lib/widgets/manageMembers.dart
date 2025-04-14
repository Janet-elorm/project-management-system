import 'package:capstone_flutter/api_service/invite_service.dart';
import 'package:flutter/material.dart';
import 'projectdata.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ManageMembersPopup extends StatefulWidget {
  final Project project;

  const ManageMembersPopup({super.key, required this.project});

  @override
  State<ManageMembersPopup> createState() => _ManageMembersPopupState();
}

class _ManageMembersPopupState extends State<ManageMembersPopup> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isEmailValid = false;

  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _sendInvite() async {
    setState(() => _isLoading = true);

    try {
      final token = await _getAuthToken();
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication error. Please log in again.')),
        );
        setState(() => _isLoading = false);
        return;
      }

      final inviteService = InviteService();
      await inviteService.sendInvite(
        widget.project.projectId,
        _emailController.text,
        token,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invite sent successfully!')),
      );
      _emailController.clear();
      setState(() => _isEmailValid = false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send invite: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Invite to Workspace'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email address or name',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            onChanged: (value) {
              setState(() => _isEmailValid = _isValidEmail(value));
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Invite someone to this Workspace with a link:'),
              ElevatedButton.icon(
                onPressed: _isLoading || !_isEmailValid ? null : _sendInvite,
                icon: const Icon(Icons.send, size: 16),
                label: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Send Invite'),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
