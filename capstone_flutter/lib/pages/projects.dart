import 'package:capstone_flutter/pages/dashboard.dart';
import 'package:capstone_flutter/pages/progressTracker.dart';
import 'package:capstone_flutter/widgets/mainLayout.dart';
import 'package:flutter/material.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({Key? key}) : super(key: key);

  @override
  _ProjectsPageState createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  String selectedPage = "Progress Tracker";

  

  void handlePageSelected(String page) {
    setState(() {
      selectedPage = page;
    });

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Projects",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
