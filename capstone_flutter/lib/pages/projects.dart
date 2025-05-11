import 'dart:convert';
import 'package:capstone_flutter/pages/dashboard.dart';
import 'package:capstone_flutter/pages/progressTracker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:capstone_flutter/widgets/projectdata.dart';
import 'package:capstone_flutter/widgets/sidebar.dart';
import 'package:capstone_flutter/widgets/topbar.dart';

class ProjectsPage extends StatefulWidget {
  final int projectId;
  const ProjectsPage({Key? key, required this.projectId}) : super(key: key);

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

  void _showProjectMembersPopup(BuildContext context, int projectId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse(
            'http://127.0.0.1:8000/dashboard/projects/$projectId/members'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> members = json.decode(response.body);

        showDialog(
          context: context,
          builder: (_) => Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 300, vertical: 100),
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Project Members",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (members.isEmpty)
                    const Text(
                      "No members assigned to this project.",
                      style: TextStyle(
                          fontStyle: FontStyle.italic, color: Colors.grey),
                    )
                  else
                    Column(
                      children: [
                        // Header Row
                        Row(
                          children: const [
                            Expanded(
                                flex: 3,
                                child: Text("Name",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600))),
                            Expanded(
                                flex: 3,
                                child: Text("Email",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600))),
                            Expanded(
                                flex: 2,
                                child: Text("Assigned",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600))),
                            Expanded(
                                flex: 2,
                                child: Text("Completed",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600))),
                          ],
                        ),
                        const Divider(
                            thickness: 0.5, height: 12, color: Colors.grey),
                        // Data Rows
                        ...members.map((member) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Expanded(
                                      flex: 3,
                                      child: Text(member['full_name'] ?? '',
                                          overflow: TextOverflow.ellipsis)),
                                  Expanded(
                                      flex: 3,
                                      child: Text(member['email'] ?? '',
                                          overflow: TextOverflow.ellipsis)),
                                  Expanded(
                                      flex: 2,
                                      child:
                                          Text('${member['assigned_tasks']}')),
                                  Expanded(
                                      flex: 2,
                                      child:
                                          Text('${member['completed_tasks']}')),
                                ],
                              ),
                            )),
                      ],
                    ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Close"),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      } else {
        throw Exception("Failed to load members: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error showing members: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load project members")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Row(
  children: [
    // Sidebar
    SizedBox(
      width: 220, // fixed width for sidebar
      child: Sidebar(
        selectedPage: 'Projects',
        onPageSelected: (page) {
          if (page == 'Dashboard') {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => DashboardPage(),
                transitionsBuilder: (_, animation, __, child) =>
                    FadeTransition(opacity: animation, child: child),
                transitionDuration: const Duration(milliseconds: 300),
              ),
            );
          } else if (page == 'Projects') {
            // Do nothing
          } else if (page == 'Progress Tracker') {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => ProgressTrackingPage(projectId: widget.projectId),
                transitionsBuilder: (_, animation, __, child) =>
                    FadeTransition(opacity: animation, child: child),
                transitionDuration: const Duration(milliseconds: 300),
              ),
            );
          }
        },
      ),
    ),
          Expanded(
            child: Column(
              children: [
                TopBar(apiBaseUrl: 'http://127.0.0.1:8000', projectId:widget.projectId),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: Row(
                    children: [
                      const Text(
                        "Projects",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () {
                          // handle create
                        },
                        icon: const Icon(Icons.add),
                        label: const Text("Add Project"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 190, 198, 208),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: ['All', 'Started', 'Completed'].map((status) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(status),
                          selected: filter == status,
                          onSelected: (_) => setState(() => filter = status),
                          selectedColor: Color.fromARGB(255, 190, 198, 208),
                          labelStyle: TextStyle(
                            color:
                                filter == status ? Colors.white : Colors.black,
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
          Expanded(
              flex: 3,
              child: Text('Project Name',
                  style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
              flex: 2,
              child: Text('Created By',
                  style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
              flex: 2,
              child: Text('Members',
                  style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
              flex: 3,
              child: Text('Progress',
                  style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
              flex: 2,
              child: Text('Deadline',
                  style: TextStyle(fontWeight: FontWeight.bold))),
          SizedBox(width: 40), // space for popup menu icon
        ],
      ),
    );
  }

  Widget _buildProjectRow(Project project) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
              flex: 3,
              child: Text(project.title,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600))),
          Expanded(
              flex: 2,
              child: Text(project.creatorName,
                  style: const TextStyle(fontSize: 13, color: Colors.grey))),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () => _showProjectMembersPopup(context, project.projectId),
              child: Text(
                '${project.teamCount} ${project.teamCount == 0 ? "Member" : "Members"}',
                style: const TextStyle(
                  fontSize: 13,
                  color:  Color.fromARGB(255, 190, 198, 208),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: project.progress,
                  minHeight: 6,
                  backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 171, 184, 195)),
                ),
                const SizedBox(height: 4),
                Text('${(project.progress * 100).toInt()}%',
                    style:
                        const TextStyle(fontSize: 12, color: Colors.black87)),
              ],
            ),
          ),
          Expanded(
              flex: 2,
              child:
                  Text("N/A", style: TextStyle(color: Colors.grey.shade600))),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 20),
            onSelected: (value) {
              // handle actions
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'manage', child: Text('Manage Project')),
              PopupMenuItem(value: 'edit', child: Text('Edit Project')),
              PopupMenuItem(value: 'delete', child: Text('Delete Project')),
            ],
          ),
        ],
      ),
    );
  }
}