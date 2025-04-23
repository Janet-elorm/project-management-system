import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DashboardService {
  static const String baseUrl =
      "http://127.0.0.1:8000/dashboard"; 

  // Future<Map<String, dynamic>?> fetchDashboardData() async {
  //   final response = await http.get(Uri.parse('$baseUrl/metrics'));

  //   if (response.statusCode == 200) {
  //     return json.decode(response.body);
  //   } else {
  //     print("Failed to load dashboard data: ${response.body}");
  //     return null;
  //   }
  // }

Future<Map<String, dynamic>?> fetchDashboardData() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');

  final response = await http.get(
    Uri.parse('$baseUrl/metrics'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    print("Failed to load dashboard data: ${response.body}");
    return null;
  }
}



//   Future<List<dynamic>> fetchUpcomingDeadlines() async {
//   final response = await http.get(
//     Uri.parse('$baseUrl/upcoming-deadlines'),
//     headers: {
//       "Authorization": "Bearer $yourToken", // replace with actual token logic
//     },
//   );

//   if (response.statusCode == 200) {
//     return jsonDecode(response.body);
//   } else {
//     throw Exception("Failed to load upcoming deadlines (${response.statusCode})");
//   }
// }'



}
