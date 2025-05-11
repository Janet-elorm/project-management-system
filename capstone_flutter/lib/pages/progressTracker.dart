import 'dart:convert';
import 'package:capstone_flutter/pages/taskManager.dart';
import 'package:capstone_flutter/widgets/mini_sidebar.dart';
import 'package:capstone_flutter/widgets/projectdata.dart';
import 'package:http/http.dart' as http;
import 'package:capstone_flutter/pages/dashboard.dart';
import 'package:capstone_flutter/pages/projects.dart';
import 'package:flutter/material.dart';
import 'package:capstone_flutter/widgets/mainLayout.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

final Random _random = Random();

class ProgressTrackingPage extends StatefulWidget {
  final int projectId;
  const ProgressTrackingPage({Key? key, required this.projectId})
      : super(key: key);

  @override
  _ProgressTrackingPageState createState() => _ProgressTrackingPageState();
}

class _ProgressTrackingPageState extends State<ProgressTrackingPage> {
  String selectedPage = "Progress Tracker";
  List<Map<String, dynamic>> _projects = [];
  late int _currentProjectId;
  double? projectProgress;
  List<Map<String, dynamic>> recentActivities = [];
  List<Map<String, dynamic>> _teamMembers = [];

  @override
  void initState() {
    super.initState();
    _currentProjectId = widget.projectId;
    fetchProjects();
    fetchAndSetProgress();
    fetchRecentActivities();
    fetchTeamProgress();
  }

  Future<void> fetchTeamProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse(
          'http://127.0.0.1:8000/dashboard/projects/$_currentProjectId/members'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _teamMembers = List<Map<String, dynamic>>.from(data);
      });
    } else {
      debugPrint("Failed to fetch team progress: ${response.body}");
    }
  }

  Future<void> fetchAndSetProgress() async {
    try {
      final progress = await fetchProjectProgress(_currentProjectId);
      setState(() {
        projectProgress = progress;
      });
    } catch (e) {
      debugPrint("Error fetching progress: $e");
    }
  }

  Future<void> fetchProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/dashboard/projects/user'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _projects = List<Map<String, dynamic>>.from(data);
      });
    } else {
      debugPrint("Failed to fetch projects: ${response.body}");
    }
  }

  Future<void> fetchRecentActivities() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse(
            'http://127.0.0.1:8000/dashboard/projects/$_currentProjectId/activities'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          recentActivities = List<Map<String, dynamic>>.from(data);
        });
      } else {
        debugPrint("Failed to fetch activities: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error fetching activities: $e");
    }
  }

  String _formatTimeAgo(String timestamp) {
    final time = DateTime.parse(timestamp).toLocal();
    final diff = DateTime.now().difference(time);

    if (diff.inSeconds < 60) return "just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes} minutes ago";
    if (diff.inHours < 24) return "${diff.inHours} hours ago";
    if (diff.inDays < 7) return "${diff.inDays} days ago";
    return "${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')}";
  }

  void handlePageSelected(String page) {
    if (page == "Dashboard") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    } else if (page == "Progress Tracker") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ProgressTrackingPage(projectId: widget.projectId),
        ),
      );
      } else if (page == "Task Manager") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              TaskManagerPage(projectId: widget.projectId),
        ),
      );
    } else if (page == "Projects") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ProjectsPage(projectId: widget.projectId)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      selectedPage: selectedPage,
      onPageSelected: handlePageSelected,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Keep only one MiniSidebar (left-aligned beside sidebar)
            MiniSidebar(
              selectedProjectId: _currentProjectId,
              onProjectSelected: (projectId) {
                setState(() {
                  _currentProjectId = projectId;
                  fetchAndSetProgress();
                  fetchRecentActivities();
                  fetchTeamProgress();
                });
              },
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildRecentActivities(),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 1,
              child: _buildTeamProgress(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Progress Tracker",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: projectProgress ?? 0.0,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      Color.fromARGB(255, 0, 0, 0)),
                  minHeight: 10,
                ),
                Text(
                  "${((projectProgress ?? 0.0) * 100).toInt()}% Completed",
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                const SizedBox(height: 10),
                // Text(
                //   "65% Completed",
                //   style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                // ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivities() {
  return Expanded(
    child: Container(
      width: double.infinity,  // ✅ Stretch to full width
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Recent Activities",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Expanded(
            child: recentActivities.isEmpty
                ? Center(
                    child: Text("No recent activities yet",
                        style: TextStyle(color: Colors.grey)))
                : ListView(
                    children: recentActivities.map((activity) {
                      return ListTile(
                        leading: Icon(Icons.history,
                            color: Colors.blueGrey, size: 20),
                        title: Text(
                          "${activity['user']} ${activity['action']} '${activity['task']}'",
                          style: TextStyle(fontSize: 13),
                        ),
                        subtitle: Text(
                          _formatTimeAgo(activity['timestamp']),
                          style:
                              TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                      );
                    }).toList(),
                  ),
          )
        ],
      ),
    ),
  );
}


  Widget _buildTeamProgress() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Team Progress",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          _teamMembers.isEmpty
              ? Text("No team data yet", style: TextStyle(color: Colors.grey))
              : Expanded(
                  child: ListView(
                    children: _teamMembers.map((member) {
                      return Card(
                        color: Color(0xFFE8EEF1),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                  'https://via.placeholder.com/150')),
                          title: Text(member['name'] ?? 'Unknown',
                              style: TextStyle(fontSize: 12)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LinearProgressIndicator(
                                value: member['progress']?.toDouble() ?? 0.0,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.blueGrey),
                                minHeight: 6,
                              ),
                              SizedBox(height: 4),
                              Text(
                                  "Tasks: ${member['tasks_completed']}/${member['tasks_total']} | Overdue: ${member['overdue_tasks']}",
                                  style: TextStyle(fontSize: 11))
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
    );
  }
}
