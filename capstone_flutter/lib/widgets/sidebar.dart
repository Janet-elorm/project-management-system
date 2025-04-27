import 'package:capstone_flutter/pages/progressTracker.dart';
import 'package:capstone_flutter/pages/taskManager.dart';
import 'package:capstone_flutter/widgets/projectdata.dart';
import 'package:flutter/material.dart';

class Sidebar extends StatefulWidget {
  final String selectedPage;
  final Function(String) onPageSelected;

  const Sidebar({
    Key? key,
    required this.selectedPage,
    required this.onPageSelected,
  }) : super(key: key);

  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  List<Project> projects = [];
  bool isProjectsExpanded = true;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProjects();
  }

  Future<void> loadProjects() async {
    try {
      final loadedProjects = await fetchProjects();
      setState(() {
        projects = loadedProjects;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Failed to fetch projects: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: const Color.fromARGB(255, 218, 222, 228),
      child: ListView(
        padding: EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Image.asset(
              'assets/onboard-removebg-preview.png',
              height: 40,
              alignment: Alignment.centerLeft,
            ),
          ),

          _buildSectionTitle('NAVIGATION'),
          _buildNavItem('Dashboard', Icons.home_outlined),
          _buildNavItem('Progress Tracker', Icons.timeline_outlined),

          const SizedBox(height: 24),
          _buildSectionTitle('PROJECTS'),
          _buildProjectsHeader(),

          if (isProjectsExpanded) ...[
  if (isLoading)
    const Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Center(child: CircularProgressIndicator()),
    )
  else
    ..._buildProjectList(), // ✅ Add the three dots here
],
        ]

      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildNavItem(String title, IconData icon) {
    bool selected = widget.selectedPage == title;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: selected
          ? BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                )
              ],
            )
          : null,
      child: ListTile(
        dense: true,
        leading: Icon(
          icon,
          size: 20,
          color: selected ? Colors.blueGrey : Colors.grey.shade700,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected ? Colors.blueGrey : Colors.black,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () => widget.onPageSelected(title),
      ),
    );
  }

  Widget _buildProjectsHeader() {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => setState(() => isProjectsExpanded = !isProjectsExpanded),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              isProjectsExpanded ? Icons.folder_open : Icons.folder,
              size: 18,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'All Projects',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              isProjectsExpanded ? Icons.expand_less : Icons.expand_more,
              size: 18,
              color: Colors.grey.shade600,
            )
          ],
        ),
      ),
    );
  }

  List<Widget> _buildProjectList() {
    return projects.map((project) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: ListTile(
          dense: true,
          leading: const Icon(Icons.folder_outlined, size: 18, color: Colors.grey),
          title: Text(
            project.title,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          trailing: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 16, color: Colors.grey),
            onSelected: (value) {
              if (value == 'tasks') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaskManagerPage(projectId: project.projectId),
                  ),
                );
              } else if (value == 'progress') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProgressTrackingPage(projectId: project.projectId),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'tasks', child: Text('Manage Tasks')),
              const PopupMenuItem(value: 'progress', child: Text('View Progress')),
            ],
          ),
        ),
      );
    }).toList();
  }
}
