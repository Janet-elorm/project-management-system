import 'dart:convert';
import 'package:http/http.dart' as http;

class InviteService {
  final String baseUrl = "http://127.0.0.1:8000"; // Update with your API URL

  Future<Map<String, dynamic>> sendInvite(int projectId, String email, String token) async {
    final url = Uri.parse("$baseUrl/invite/projects/$projectId/invite");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"email": email}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to send invite: ${response.body}");
    }
  }
}

