// import 'package:capstone_flutter/pages/dashboard.dart';
// import 'package:capstone_flutter/pages/progressTracker.dart';
// import 'package:capstone_flutter/widgets/mainLayout.dart';
// import 'package:flutter/material.dart';

// class ProjectsPage extends StatefulWidget {
//   const ProjectsPage({Key? key}) : super(key: key);

//   @override
//   _ProjectsPageState createState() => _ProjectsPageState();
// }

// class _ProjectsPageState extends State<ProjectsPage> {
//   String selectedPage = "Progress Tracker";

  

//   void handlePageSelected(String page) {
//     setState(() {
//       selectedPage = page;
//     });

//     if (page == "Dashboard") {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const DashboardPage()),
//       );
//     } else if (page == "Progress Tracker") {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const ProgressTrackingPage()),
//       );
//     } else if (page == "Projects") {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const ProjectsPage()),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MainLayout(
//       selectedPage: selectedPage,
//       onPageSelected: handlePageSelected,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: const [
//             Text(
//               "Projects",
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// projects_page.dart
import 'package:flutter/material.dart';
import 'package:capstone_flutter/widgets/projectdata.dart'; // For fetching projects

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  List<Project> projects = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProjects();
  }

  Future<void> loadProjects() async {
    try {
      final loaded = await fetchProjects();
      setState(() {
        projects = loaded;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Error loading projects: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Projects')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : projects.isEmpty
                ? const Center(child: Text("No projects available."))
                : GridView.builder(
                    itemCount: projects.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2,
                    ),
                    itemBuilder: (context, index) {
                      final project = projects[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                project.title,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                project.description,
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.grey),
                              ),
                              const Spacer(),
                              LinearProgressIndicator(
                                value: project.progress,
                                minHeight: 5,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Color(0xFF805AD5)),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
