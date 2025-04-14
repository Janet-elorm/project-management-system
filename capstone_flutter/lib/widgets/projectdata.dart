import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// projectdata.dart
class Project {
  final int projectId;
  final String title;
  final String workspace;
  final double progress;
  final int teamCount;
  final List<String> teamAvatars;
  final String description; // Add description

  Project({
    required this.projectId,
    required this.title,
    required this.workspace,
    required this.progress,
    required this.teamCount,
    required this.teamAvatars,
    required this.description, // Include in constructor
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      projectId: json['project_id'],
      title: json['title'],
      workspace: json['workspace'] ?? '',
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      teamCount: json['team_count'] ?? 0,
      teamAvatars: List<String>.from(json['team_members'] ?? []),
      description: json['description'] ?? '', // Map description
    );
  }
}

// Future<List<Project>> fetchProjects() async {
//   final response = await http.get(Uri.parse('http://127.0.0.1:8000/dashboard/projects'));

//   if (response.statusCode == 200) {
//     List<dynamic> jsonData = json.decode(response.body);
//     return jsonData.map((json) => Project.fromJson(json)).toList();
//   } else {
//     throw Exception('Failed to load projects');
//   }
// }

Future<List<Project>> fetchProjects() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');

  final response = await http.get(
    Uri.parse('http://127.0.0.1:8000/dashboard/projects/{project_id}'),
    headers: {
      'Authorization': 'Bearer $token',
    },
    
  );

  if (response.statusCode == 200) {
    List<dynamic> jsonData = json.decode(response.body);
    return jsonData.map((json) => Project.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load projects');
  }
}


// Future<Project> createProject(String title, String workspace, String description) async {
//   final response = await http.post(
//     Uri.parse('http://127.0.0.1:8000/dashboard/projects'),
//     headers: <String, String>{
//       'Content-Type': 'application/json; charset=UTF-8',
//     },
//     body: jsonEncode(<String, dynamic>{ // Use dynamic for values
//       'title': title,
//       'workspace': workspace,
//       'description': description,
//       'progress': 0.0,
//       'team_count': 1,
//       'team_members': [],
//     }),
//   );

//   if (response.statusCode == 201) {
//     print("Create Project Response: ${response.body}"); // Add this line
//     return Project.fromJson(jsonDecode(response.body));
//   } else {
//     throw Exception('Failed to create project');
//   }
// }

Future<Project> createProject(String title, String workspace, String description) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');

  final response = await http.post(
    Uri.parse('http://127.0.0.1:8000/dashboard/projects/all'), // Note the /all endpoint
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(<String, dynamic>{
      'title': title,
      'workspace': workspace,
      'project_description': description, // Match your schema
      'progress': 0.0,
      'team_count': 1,
      'team_members': [],
    }),
  );

  if (response.statusCode == 200) { // Or 201 depending on your API
    return Project.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to create project: ${response.body}');
  }
}