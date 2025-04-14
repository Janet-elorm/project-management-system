import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TaskManagerService {
  static const String baseUrl =
      "http://127.0.0.1:8000/dashboard"; // Adjust to match backend URL

  Future<List<Map<String, dynamic>>> fetchProjectMembers(int projectId) async {
    final response = await http.get(
      Uri.parse('$baseUrl projects/$projectId/members'),
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load project members');
    }
  }

  Future<Map<String, dynamic>> fetchProjectDetails(int projectId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/projects/$projectId'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load project (${response.statusCode})");
    }
  }

  Future<void> createTask(Map<String, dynamic> taskData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tasks'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(taskData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("✅ Task added successfully");
    } else {
      throw Exception("❌ Failed to add task: ${response.body}");
    }
  }

  Future<List<dynamic>> fetchProjectTasks(int projectId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/projects/$projectId/tasks'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load tasks (${response.statusCode})");
    }
  }

  Future<void> updateTaskCategory(int taskId, String category) async {
    final response = await http.put(
      Uri.parse('$baseUrl/tasks/$taskId/category?category=$category'),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update task category: ${response.body}");
    }
  }

  Future<void> deleteTask(int taskId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/tasks/$taskId'),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to delete task: ${response.body}");
    }
  }

  Future<List<Map<String, dynamic>>> fetchAssignedTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('$baseUrl/assigned-tasks'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception("Failed to fetch assigned tasks: ${response.body}");
    }
  }
}
