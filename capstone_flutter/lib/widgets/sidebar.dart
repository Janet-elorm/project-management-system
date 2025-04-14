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
      setState(() {
        isLoading = false;
      });
      debugPrint("Failed to fetch projects: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: const Color(0xFFF5F5F5),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Logo with tighter padding
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12), // Reduced bottom padding
            child: Image.asset(
              'assets/onboard-removebg-preview.png',
              height: 36, // Slightly reduced height
              alignment: Alignment.centerLeft,
            ),
          ),

          // Navigation Section
          _buildSectionHeader('NAVIGATION'),
          _buildNavItem(
            title: 'Dashboard',
            icon: Icons.home_outlined,
            isSelected: widget.selectedPage == 'Dashboard',
          ),
          _buildNavItem(
            title: 'Progress Tracker',
            icon: Icons.timeline_outlined,
            isSelected: widget.selectedPage == 'Progress Tracker',
          ),

          // Projects Section
          _buildSectionHeader('PROJECTS'),
          _buildProjectHeader(),
          if (isProjectsExpanded) ...[
            if (isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0), // Reduced padding
                child: Center(child: CircularProgressIndicator()),
              )
            else
              ..._buildProjectList(),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4), // Reduced top padding
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required String title,
    required IconData icon,
    required bool isSelected,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), // Reduced vertical padding
      minVerticalPadding: 0, // Removes extra vertical padding
      dense: true, // Makes the ListTile more compact
      horizontalTitleGap: 2, // Reduced gap between icon and text
      leading: Icon(
        icon,
        size: 18, // Slightly smaller icon
        color: isSelected ? Colors.blue : Colors.grey.shade700,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 13, // Slightly smaller font
          color: isSelected ? Colors.blue : Colors.black,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      onTap: () => widget.onPageSelected(title),
    );
  }

  Widget _buildProjectHeader() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0), // Tight vertical padding
      minVerticalPadding: 0,
      dense: true,
      horizontalTitleGap: 2,
      leading: Icon(
        isProjectsExpanded ? Icons.folder_open : Icons.folder,
        size: 18,
        color: Colors.grey.shade700,
      ),
      title: const Text(
        'All Projects',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: IconButton(
        icon: Icon(
          isProjectsExpanded ? Icons.expand_less : Icons.expand_more,
          size: 18,
        ),
        onPressed: () {
          setState(() => isProjectsExpanded = !isProjectsExpanded);
        },
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
      onTap: () => widget.onPageSelected('Projects'),
    );
  }

  List<Widget> _buildProjectList() {
    return projects
        .map((project) => ListTile(
              contentPadding: const EdgeInsets.fromLTRB(24, 0, 4, 0), // Reduced left padding
              minVerticalPadding: 0,
              dense: true,
              horizontalTitleGap: 2,
              leading: const Icon(
                Icons.folder_outlined,
                size: 18,
                color: Colors.grey,
              ),
              title: Text(
                project.title,
                style: const TextStyle(fontSize: 13),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                size: 14,
                color: Colors.grey,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProjectTaskManager(
                        projectId: project.projectId.toString()),
                  ),
                );
              },
            ))
        .toList();
  }
}

class ProjectTaskManager extends StatelessWidget {
  final String projectId;

  const ProjectTaskManager({Key? key, required this.projectId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Project $projectId'),
      ),
      body: Center(
        child: Text('Task management for project $projectId'),
      ),
    );
  }
}