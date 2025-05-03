import 'dart:convert';
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
    List<String> actions = ["completed", "edited", "added", "deleted"];
    List<Map<String, String>> activities = [
      {"name": "Constance", "task": "Social Media Publicity", "time": "1 hour ago"},
      {"name": "Elorm", "task": "Build UI for homepage", "time": "2 hours ago"},
      {"name": "Olivia", "task": "Print new signage", "time": "3 hours ago"},
      {"name": "Elorm", "task": "Conduct final user testing", "time": "5 hours ago"},
      {"name": "Constance", "task": "Update product pages", "time": "7 hours ago"},
      {"name": "Elorm", "task": "Define app requirements", "time": "12 hours ago"},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Recent Activities", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          ...activities.map((activity) {
            String action = actions[_random.nextInt(actions.length)];
            return ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
              title: Text("${activity['name']} $action '${activity['task']}'", style: TextStyle(fontSize: 13)),
              subtitle: Text(activity['time']!, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
            );
          })
        ],
      ),
    );
  }

  Widget _buildTeamProgress() {
    List<Map<String, dynamic>> teamMembers = [
      {"name": "Constance Antwi", "tasks": "5/7", "overdue": "1", "progress": 0.71},
      {"name": "Olivia Mawuena", "tasks": "4/6", "overdue": "0", "progress": 0.66},
      {"name": "Elorm Ashigbui", "tasks": "4/9", "overdue": "0", "progress": 0.44},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Team Progress", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          ...teamMembers.map((member) => Card(
                color: Color(0xFFE8EEF1),
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(backgroundImage: NetworkImage('https://via.placeholder.com/150')),
                  title: Text(member['name'], style: TextStyle(fontSize: 12)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LinearProgressIndicator(
                        value: member['progress'],
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blueGrey),
                        minHeight: 6,
                      ),
                      SizedBox(height: 4),
                      Text("Tasks: ${member['tasks']} | Overdue: ${member['overdue']}", style: TextStyle(fontSize: 11))
                    ],
                  ),
                ),
              ))
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
