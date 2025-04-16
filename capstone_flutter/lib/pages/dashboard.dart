import 'package:capstone_flutter/api_service/invite_service.dart';
import 'package:capstone_flutter/api_service/task_manager_service.dart';
import 'package:capstone_flutter/widgets/avatar.dart';
import 'package:capstone_flutter/widgets/manageMembers.dart';
import 'package:capstone_flutter/widgets/projectdata.dart';
import 'package:flutter/material.dart';
import 'package:capstone_flutter/widgets/mainLayout.dart';
import 'package:capstone_flutter/pages/progressTracker.dart';
import 'package:capstone_flutter/pages/projects.dart';
import 'package:capstone_flutter/pages/taskManager.dart';
import 'package:capstone_flutter/api_service/dashboard_service.dart';
import 'package:capstone_flutter/widgets/upcomnigDeadlines.dart';

class DashboardPage extends StatefulWidget {
  final int? projectId;
  const DashboardPage({Key? key, this.projectId}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String selectedPage = "Dashboard";
  final DashboardService _dashboardService = DashboardService();
  final InviteService inviteService = InviteService();
  Map<String, dynamic>? dashboardData;
  List<Project> projects = [];
  bool isLoading = true;
  bool hasError = false;
  bool isProjectsLoading = true;
  bool hasProjectsError = false;
  List<dynamic> assignedTasks = [];
  int _selectedTabIndex = 0;
  final List<String> _taskTabs = ["To Do", "Completed", "In Progress"];
  List<dynamic> upcomingDeadlines = [];



  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _workspaceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadDashboardData();
    loadProjectsData();
    _loadAssignedTasks();
     // _loadUpcomingDeadlines();
  }

  Future<void> loadDashboardData() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      var data = await _dashboardService.fetchDashboardData();
      print("🔹 Dashboard Data Fetched: $data");

      setState(() {
        dashboardData = data;
      });
    } catch (e) {
      print("Error fetching dashboard data: $e");
      setState(() {
        hasError = true;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> loadProjectsData() async {
    setState(() {
      isProjectsLoading = true;
      hasProjectsError = false;
      projects = []; // Clear previous data
    });
    try {
      final fetchedProjects = await fetchProjects();
      setState(() {
        projects = fetchedProjects;
      });
    } catch (e) {
      setState(() {
        hasProjectsError = true;
        print("Error loading projects: $e"); // This should print the error
      });
    } finally {
      setState(() {
        isProjectsLoading = false;
      });
    }
  }

  void _loadAssignedTasks() async {
    try {
      assignedTasks = await TaskManagerService().fetchAssignedTasks();
      setState(() {});
    } catch (e) {
      print("❌ Failed to fetch assigned tasks: $e");
    }
  }

  void _showCreateProjectPopupMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create New Project'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a project title';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _workspaceController,
                    decoration: const InputDecoration(labelText: 'Workspace'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a workspace';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3, // Allows for multiple lines of description
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Add Members:'),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          // TODO: Implement add members functionality later
                          print("Add members button pressed");
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _createProject(); // Call the create project function
                        Navigator.of(context).pop(); // Close the dialog
                      }
                    },
                    child: const Text('Create Project'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _createProject() async {
    try {
      await createProject(
        _titleController.text,
        _workspaceController.text,
        _descriptionController.text,
      );

      // ✅ Manually add the new project to the list *before* refreshing API
      setState(() {
        projects.add(Project(
          projectId: DateTime.now().millisecondsSinceEpoch, // Temporary ID
          title: _titleController.text,
          workspace: _workspaceController.text,
          progress: 0.0, // New projects start at 0% progress
          teamCount: 1, // Default value, update if needed
          teamAvatars: [], // Provide an empty list if no avatars yet
          description: _descriptionController.text, // Description added
        ));
      });

      // ✅ Clear input fields immediately after adding
      _titleController.clear();
      _workspaceController.clear();
      _descriptionController.clear();

      // ✅ Refresh projects from API after UI updates
      await loadProjectsData();

      // ✅ Show success message only after everything is updated
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Project created successfully!')),
      );
    } catch (e) {
      print("Error creating project: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create project: $e')),
      );
    }
  }

  void handlePageSelected(String page) {
    setState(() => selectedPage = page);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => page == "Dashboard"
            ? TaskManagerPage(
                projectId: widget.projectId ?? 0) // Use widget.projectId
            : page == "Progress Tracker"
                ? ProgressTrackingPage(projectId: widget.projectId ?? 0,)
                : const ProjectsPage(),
      ),
    );
  }

//   void _loadUpcomingDeadlines() async {
//   try {
//     final deadlines = await TaskManagerService().fetchUpcomingDeadlines();
//     setState(() {
//       upcomingDeadlines = deadlines;
//     });
//   } catch (e) {
//     print("Error loading deadlines: $e");
//   }
// }


  @override
@override
Widget build(BuildContext context) {
  return MainLayout(
    selectedPage: selectedPage,
    onPageSelected: handlePageSelected,
    child: SingleChildScrollView(
      child: IntrinsicHeight(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : hasError || dashboardData == null
                  ? const Center(child: Text("Failed to load data."))
                  : _buildDashboardContent(),
        ),
      ),
    ),
  );
}

  Widget _buildDashboardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // DASHBOARD METRICS ROW
        Row(
          children: [
            _buildDashboardCard(
              title: "Total Projects",
              value: "${dashboardData?['total_projects'] ?? 0}",
              percentageChange: "76% Up this month",
              lineColor: Colors.blue,
              icon: Icons.folder_open,
            ),
            const SizedBox(width: 8),
            _buildDashboardCard(
              title: "Total Tasks",
              value: "${dashboardData?['total_tasks'] ?? 0}",
              percentageChange: "13% Up this month",
              lineColor: Colors.orange,
              icon: Icons.list_alt,
            ),
            const SizedBox(width: 8),
            _buildDashboardCard(
              title: "Assigned Tasks",
              value: "${dashboardData?['assigned_tasks'] ?? 0}",
              percentageChange: "23% Down this month",
              lineColor: Colors.purple,
              icon: Icons.person,
            ),
            const SizedBox(width: 8),
            _buildDashboardCard(
              title: "Overdue Tasks",
              value: "${dashboardData?['overdue_tasks'] ?? 0}",
              percentageChange: "14% Up this month",
              lineColor: Colors.red,
              icon: Icons.access_time,
            ),
            const SizedBox(width: 8),
            _buildDashboardCard(
              title: "Completed Tasks",
              value: "${dashboardData?['completed_tasks'] ?? 0}",
              percentageChange: "35% Down this month",
              lineColor: Colors.green,
              icon: Icons.check_circle_outline,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ASSIGNED TASKS & PROJECT OVERVIEW SECTIONS
        Expanded(
          child: Row(
            children: [
              Expanded(flex: 1, child: _buildAssignedTasksSection()),
              const SizedBox(width: 16),
              Expanded(flex: 1, child: buildProjectOverview()),
            ],
          ),
        ),
        const SizedBox(height: 25),
        UpcomingDeadlinesSection(deadlines: upcomingDeadlines),
      ],
    );
  }

  Widget _buildDashboardCard({
    required String title,
    required String value,
    required String percentageChange,
    required Color lineColor,
    required IconData icon,
  }) {
    return Expanded(
      child: SizedBox(
        height: 103,
        child: Card(
          color: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          elevation: 3,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(value,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          Icon(icon, color: Colors.grey),
                        ]),
                    Text(title,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(percentageChange,
                        style: TextStyle(fontSize: 10, color: Colors.green)),
                  ],
                ),
              ),
              // Add back the bottom-colored line
              Container(
                height: 3,
                decoration: BoxDecoration(
                  color: lineColor,
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(8)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

Widget _buildTaskTabs() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.end, // aligns tabs to the right
    children: List.generate(_taskTabs.length * 2 - 1, (index) {
      if (index.isOdd) {
        // Insert spacing between tab buttons
        return const SizedBox(width: 8);
      }

      int tabIndex = index ~/ 2;
      final isSelected = tabIndex == _selectedTabIndex;

      return GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = tabIndex;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color.fromARGB(255, 201, 210, 218)
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            _taskTabs[tabIndex],
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.normal,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      );
    }),
  );
}


Widget _buildAssignedTasksSection() {
  // Filter assigned tasks based on selected tab
  List filteredTasks = assignedTasks.where((task) {
    final category = task['category']?.toLowerCase() ?? "";
    switch (_selectedTabIndex) {
      case 0: // To Do
        return category == "to do";
      case 1: // Completed
        return category == "completed";
      case 2: // In Progress
        return category == "in progress";
      default:
        return false;
    }
  }).toList();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Assigned Tasks',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
        child: SizedBox(
          height: 320, // match Project Overview card height
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Your Tasks", style: TextStyle(fontSize: 12)),
                    _buildTaskTabs(),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: filteredTasks.isEmpty
                      ? const Center(child: Text("No tasks in this category."))
                      : GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // 2 cards per row
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 2, // Adjust this for card proportions
                          ),
                          itemCount: filteredTasks.length,
                          itemBuilder: (context, index) {
                            final task = filteredTasks[index];
                            return _buildTaskCard(
                              task['title'] ?? 'No title',
                              task['category'] ?? 'No category',
                              task['due_date']?.toString() ?? 'No due date',
                              task['priority'] ?? 'Medium',
                              task['progress']?.toDouble() ?? 0.0,
                            );
                          },
                        ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}



  Widget buildProjectOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Project Overview',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Card(
          color: Colors.white,
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: SizedBox(
            height: 320, // Set fixed height
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "All Projects",
                        style: TextStyle(fontSize: 12),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _showCreateProjectPopupMenu(context);
                        }, // Add project creation functionality
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: Colors.black12),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.add, color: Colors.black),
                            SizedBox(width: 4),
                            Text("Create Project",
                                style: TextStyle(color: Colors.black)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Loading or Empty State
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (projects.isEmpty)
                    const Center(child: Text("No projects available."))
                  else
                    Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // 2 projects per row
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 2, // Adjust height
                        ),
                        itemCount: projects.length,
                        itemBuilder: (context, index) {
                          return buildProjectCard(projects[index]);
                          
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
      
    );
  }


  Widget buildProjectCard(Project project) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  TaskManagerPage(projectId: project.projectId),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity(),
          child: Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            color: Colors.white,
            child: SizedBox(
              height: 180,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            project.title,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'manage_members') {
                              showDialog(
                                context: context,
                                builder: (context) =>
                                    ManageMembersPopup(project: project),
                              );
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'manage_members',
                              child: Text('Manage Members'),
                            ),
                            const PopupMenuItem(
                              value: 'edit_project',
                              child: Text('Edit Project'),
                            ),
                            const PopupMenuItem(
                              value: 'delete_project',
                              child: Text('Delete Project'),
                            ),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      project.workspace,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.chat_bubble_outline,
                            size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text("${project.teamCount}/8",
                            style: const TextStyle(fontSize: 10)),
                        const Spacer(),
                        ...project.teamAvatars
                            .map((avatar) => buildAvatar(avatar)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        LinearProgressIndicator(
                          value: project.progress,
                          backgroundColor: Colors.grey[300],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.purple),
                          minHeight: 3,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text("${(project.progress * 100).toInt()}%",
                              style: const TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getPriorityColor(priority).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        priority,
        style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: _getPriorityColor(priority)),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  Widget _buildTaskCard(String title, String category, String dueDate,
    String priority, double progress) {
  return Card(
    color: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    child: SizedBox(
      height: 80,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(title,
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                _buildPriorityBadge(priority),
              ],
            ),
            Text('In $category',
                style: const TextStyle(fontSize: 10, color: Colors.grey)),
            Text('Due: $dueDate', style: const TextStyle(fontSize: 10)),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Color(0xFFF5F5F5),
              valueColor: AlwaysStoppedAnimation<Color>(
                  Color.fromARGB(255, 201, 210, 218)),
              minHeight: 5,
            ),
          ],
        ),
      ),
    ),
  );
  
}
}
