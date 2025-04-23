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
  final String description;
  final String creatorName;
 // Add description

  Project({
    required this.projectId,
    required this.title,
    required this.workspace,
    required this.progress,
    required this.teamCount,
    required this.teamAvatars,
    required this.description, 
    required this.creatorName,// Include in constructor
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      projectId: json['project_id'],
      title: json['title'],
      workspace: json['workspace'] ?? '',
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      teamCount: json['team_count'] ?? 0,
      teamAvatars: List<String>.from(json['team_members'] ?? []),
      description: json['description'] ?? '',
      creatorName: json['creator_name'] ?? 'Unknown', // Map description
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

Future<List<Project>> fetchProjectsWithCreators() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');

  final response = await http.get(
    Uri.parse('http://127.0.0.1:8000/dashboard/projects/all'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = json.decode(response.body);
    return jsonData.map((json) => Project.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load projects with creators');
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

Future<Project> updateProject(int projectId, String title, String description) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');

  final response = await http.put(
    Uri.parse('http://127.0.0.1:8000/dashboard/projects/$projectId'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      'title': title,
      'description': description,
    }),
  );

  if (response.statusCode == 200) {
    return Project.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to update project');
  }
}

Future<void> removeTeamMember(int projectId, String userId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');

  final response = await http.delete(
    Uri.parse('http://127.0.0.1:8000/dashboard/projects/$projectId/members/$userId'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to remove team member');
  }
}
class ProjectTeamMember {
  final int userId;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final double contribution;

  ProjectTeamMember({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.contribution,
  });

  String get fullName => '$firstName $lastName';

  factory ProjectTeamMember.fromJson(Map<String, dynamic> json) {
    return ProjectTeamMember(
      userId: json['user_id'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'Member',
      contribution: (json['contribution'] as num?)?.toDouble() ?? 0.0,
    );
  }
}


Future<List<ProjectTeamMember>> fetchProjectMembers(int projectId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');

  final response = await http.get(
    Uri.parse('http://127.0.0.1:8000/projects/$projectId/members'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = json.decode(response.body);
    return jsonData.map((json) => ProjectTeamMember.fromJson(json)).toList();
  } else if (response.statusCode == 404) {
    throw Exception('No members found for this project');
  } else {
    throw Exception('Failed to load project members: ${response.statusCode}');
  }
}

Future<void> deleteProject(int projectId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');

  final response = await http.delete(
    Uri.parse('http://127.0.0.1:8000/dashboard/projects/$projectId'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    print("✅ Project deleted successfully");
  } else {
    print("❌ Failed to delete project: ${response.body}");
    throw Exception('Failed to delete project');
  }
}
