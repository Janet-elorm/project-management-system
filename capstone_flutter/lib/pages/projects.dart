import 'package:flutter/material.dart';
import 'package:capstone_flutter/widgets/projectdata.dart';
import 'package:capstone_flutter/widgets/sidebar.dart';
import 'package:capstone_flutter/widgets/topbar.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({Key? key}) : super(key: key);

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  List<Project> projects = [];
  bool isLoading = true;
  String filter = 'All';

  @override
  void initState() {
    super.initState();
    loadProjects();
  }

  Future<void> loadProjects() async {
    try {
      final loaded = await fetchProjectsWithCreators();
      setState(() {
        projects = loaded;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading projects: $e");
      setState(() => isLoading = false);
    }
  }

  List<Project> get filteredProjects {
    if (filter == 'Started') {
      return projects.where((p) => p.progress > 0 && p.progress < 1).toList();
    } else if (filter == 'Completed') {
      return projects.where((p) => p.progress >= 1.0).toList();
    }
    return projects;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Row(
        children: [
          Sidebar(
            selectedPage: 'Projects',
            onPageSelected: (page) {},
          ),
          Expanded(
            child: Column(
              children: [
                const TopBar(apiBaseUrl: 'http://127.0.0.1:8000'),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: Row(
                    children: [
                      const Text(
                        "Projects",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () {
                          // handle create
                        },
                        icon: const Icon(Icons.add),
                        label: const Text("Add Project"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: ['All', 'Started', 'Completed'].map((status) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(status),
                          selected: filter == status,
                          onSelected: (_) => setState(() => filter = status),
                          selectedColor: Colors.blueGrey,
                          labelStyle: TextStyle(
                            color: filter == status ? Colors.white : Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                _buildHeaderRow(),
                const Divider(height: 0),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.separated(
                          itemCount: filteredProjects.length,
                          separatorBuilder: (_, __) => const Divider(height: 0),
                          itemBuilder: (context, index) {
                            final project = filteredProjects[index];
                            return _buildProjectRow(project);
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: const [
          Expanded(flex: 3, child: Text('Project Name', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('Created By', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 3, child: Text('Progress', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('Deadline', style: TextStyle(fontWeight: FontWeight.bold))),
          SizedBox(width: 40), // for menu icon
        ],
      ),
    );
  }

  Widget _buildProjectRow(Project project) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(project.title, style: const TextStyle(fontSize: 14))),
          Expanded(flex: 2, child: Text(project.creatorName, style: const TextStyle(color: Colors.grey))),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 140, // Shortened progress bar
                  child: LinearProgressIndicator(
                    value: project.progress,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueGrey),
                  ),
                ),
                const SizedBox(height: 4),
                Text('${(project.progress * 100).toInt()}%', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          Expanded(flex: 2, child: Text("N/A", style: TextStyle(color: Colors.grey.shade600))),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'manage':
                  // TODO: Navigate to member progress page
                  break;
                case 'edit':
                  // TODO: Edit logic
                  break;
                case 'delete':
                  // TODO: Delete logic
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'manage', child: Text('Manage Project')),
              const PopupMenuItem(value: 'edit', child: Text('Edit Project')),
              const PopupMenuItem(value: 'delete', child: Text('Delete Project')),
            ],
          ),
        ],
      ),
    );
  }
}
