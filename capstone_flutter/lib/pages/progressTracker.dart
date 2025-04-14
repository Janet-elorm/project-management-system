import 'package:capstone_flutter/pages/dashboard.dart';
import 'package:capstone_flutter/pages/projects.dart';
import 'package:flutter/material.dart';
import 'package:capstone_flutter/widgets/mainLayout.dart';

class ProgressTrackingPage extends StatefulWidget {
  const ProgressTrackingPage({Key? key}) : super(key: key);

  @override
  _ProgressTrackingPageState createState() => _ProgressTrackingPageState();
}

class _ProgressTrackingPageState extends State<ProgressTrackingPage> {
  String selectedPage = "Progress Tracker";

  void handlePageSelected(String page) {
    if (page == "Dashboard") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    } else if (page == "Progress Tracker") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProgressTrackingPage()),
      );
    } else if (page == "Projects") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProjectsPage()),
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
                  value: 0.65,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 0, 0, 0)),
                  minHeight: 10,
                ),
                const SizedBox(height: 10),
                Text(
                  "65% Completed",
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
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
      leading: const Icon(Icons.check_circle, color: Color.fromARGB(255, 0, 0, 0)),
      title: const Text("John completed 'UI Design'", style: TextStyle(fontSize: 14)),
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
        title: const Text("John Doe",style: TextStyle(fontSize: 12)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: 0.75,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 0, 0, 0)),
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
