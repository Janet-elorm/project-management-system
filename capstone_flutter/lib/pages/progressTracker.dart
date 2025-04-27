import 'dart:convert';
import 'package:capstone_flutter/widgets/mini_sidebar.dart';
import 'package:capstone_flutter/widgets/projectdata.dart';
import 'package:http/http.dart' as http;
import 'package:capstone_flutter/pages/dashboard.dart';
import 'package:capstone_flutter/pages/projects.dart';
import 'package:flutter/material.dart';
import 'package:capstone_flutter/widgets/mainLayout.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  void initState() {
    super.initState();
    _currentProjectId = widget.projectId;
    fetchProjects();
    fetchAndSetProgress();
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
    } else if (page == "Projects") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ProjectsPage(projectId: widget.projectId)),
      );
    }
  }

  @override
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recent Activities",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...List.generate(6, (index) => _buildActivityTile()),
        ],
      ),
    );
  }

  Widget _buildActivityTile() {
    return ExpansionTile(
      leading:
          const Icon(Icons.check_circle, color: Color.fromARGB(255, 0, 0, 0)),
      title: const Text("John completed 'UI Design'",
          style: TextStyle(fontSize: 14)),
      subtitle: const Text("2 hours ago"),
      children: const [
        Padding(
          padding: EdgeInsets.all(12.0),
          child: Text("Details about the activity can be shown here."),
        ),
      ],
    );
  }

  Widget _buildTeamProgress() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Team Progress",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...List.generate(6, (index) => _buildTeamMemberCard()),
        ],
      ),
    );
  }

  Widget _buildTeamMemberCard() {
    return Card(
      color: const Color.fromARGB(255, 201, 210, 218),
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundImage: NetworkImage('https://via.placeholder.com/150'),
        ),
        title: const Text("John Doe", style: TextStyle(fontSize: 12)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: 0.75,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(
                  Color.fromARGB(255, 0, 0, 0)),
            ),
            const SizedBox(height: 4),
            const Text(
              "Tasks: 4/5 | Overdue: 1",
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
