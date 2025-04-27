import 'package:capstone_flutter/api_service/task_manager_service.dart';
import 'package:capstone_flutter/pages/dashboard.dart';
import 'package:capstone_flutter/pages/progressTracker.dart';
import 'package:capstone_flutter/pages/projects.dart';
import 'package:capstone_flutter/widgets/addTaskDialog.dart';
import 'package:flutter/material.dart';

class TaskManagerPage extends StatefulWidget {
  final int projectId;
  const TaskManagerPage({Key? key, required this.projectId}) : super(key: key);

  @override
  _TaskManagerPageState createState() => _TaskManagerPageState();
}

List<dynamic> project_tasks = [];

class _TaskManagerPageState extends State<TaskManagerPage> {
  String selectedPage = "Task Manager";
  Map<String, dynamic>? projectData;
  List<dynamic> tasks = [];
  bool isLoading = true;
  String? errorMessage;
  final TaskManagerService _taskService = TaskManagerService();

  @override
  void initState() {
    super.initState();
    _loadProjectData();
  }

  Future<void> _loadProjectData() async {
    try {
      print("Fetching project details for ID: ${widget.projectId}");
      final project = await _taskService.fetchProjectDetails(widget.projectId);
      print("Project data received: $project"); // Debug print

      final projectTasks =
          await _taskService.fetchProjectTasks(widget.projectId);
      print("Tasks data received: $projectTasks"); // Debug print

      setState(() {
        projectData = project as Map<String, dynamic>?;
        tasks = projectTasks;
      });
    } catch (e) {
      print("Error loading data: $e"); // Detailed error
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _loadTasks() async {
    var fetchedTasks =
        await TaskManagerService().fetchProjectTasks(widget.projectId);
    setState(() {
      tasks = fetchedTasks;
    });
  }

  Future<void> _updateCategory(int taskId, String category) async {
    await TaskManagerService().updateTaskCategory(taskId, category);
    _loadTasks(); // refresh task list
  }

  Future<void> _deleteTask(int taskId) async {
    await TaskManagerService().deleteTask(taskId);
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            color: const Color(0xFFF5F5F5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "app icon and name",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                SidebarItem(
                  title: 'Dashboard',
                  isSelected: selectedPage == "Dashboard",
                  onTap: () {
                    setState(() => selectedPage = "Dashboard");
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              DashboardPage(projectId: widget.projectId)),
                    );
                  },
                ),
                SidebarItem(
                  title: 'Progress Tracker',
                  isSelected: selectedPage == "Progress Tracker",
                  onTap: () {
                    setState(() => selectedPage = "Progress Tracker");
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProgressTrackingPage(projectId: widget.projectId),
                      ),
                    );
                  },
                ),
                SidebarItem(
                  title: 'Projects',
                  isSelected: selectedPage == "Projects",
                  onTap: () {
                    setState(() => selectedPage = "Projects");
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProjectsPage(projectId: widget.projectId)),
                    );
                  },
                ),
              ],
            ),
          ),
          // Main content
          Expanded(
            child: Column(
              children: [
                // Top bar with search, notification, and profile
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 800,
                        height: 35,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Search",
                            hintStyle: TextStyle(fontSize: 14),
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 209, 209, 209)),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.notifications),
                          ),
                          const SizedBox(width: 16),
                          Row(
                            children: [
                              const CircleAvatar(
                                backgroundImage: NetworkImage(
                                    'https://via.placeholder.com/150'),
                                radius: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "John Doe",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              projectData?['title'] ??
                                  "No title", // Changed from projectData?['project']?['title']
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            // Date Card
                            Card(
                              color: const Color(0xFFF5F5F5),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Start Date: ${projectData?['start_date'] ?? '----/--/--'}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      "Deadline: ${projectData?['deadline'] ?? '----/--/--'}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Project Description Card
                            Container(
                              height: 85,
                              width: 650,
                              child: Card(
                                color: const Color(0xFFF5F5F5),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        "Project Description:",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        projectData?['project_description'] ??
                                            "Loading...",
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Expanded(child: _buildTaskCard("To Do")),
                              const SizedBox(width: 16),
                              Expanded(child: _buildTaskCard("In Progress")),
                              const SizedBox(width: 16),
                              Expanded(child: _buildTaskCard("Completed")),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(String category) {
    // Filter tasks by category
    final filteredTasks =
        tasks.where((task) => task['category'] == category).toList();

    return Card(
      color: const Color(0xFFF5F5F5),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AddTaskDialog(
                          projectId: widget.projectId,
                          category: category,
                          onTaskAdded:
                              _loadTasks, // a function that reloads the task list
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: filteredTasks.isEmpty
                  ? const Center(child: Text("No tasks in this category"))
                  : ListView.builder(
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = filteredTasks[index];
                        return Stack(
                          alignment: Alignment.topRight,
                          children: [
                            TaskCard(
                              title: task['title'] ?? 'No title',
                              participant: task['assigned_to'] ?? 'Unassigned',
                              dateAdded: task['created_at'] ?? '----/--/--',
                              priority: task['priority'] ?? 'Medium',
                            ),
                            Positioned(
                              right: 0,
                              child: PopupMenuButton<String>(
                                icon: Icon(Icons.more_vert, size: 20),
                                onSelected: (value) async {
                                  if (value == 'progress') {
                                    await TaskManagerService()
                                        .updateTaskCategory(
                                            task['task_id'], 'In Progress');
                                    _loadTasks();
                                  } else if (value == 'completed') {
                                    await TaskManagerService()
                                        .updateTaskCategory(
                                            task['task_id'], 'Completed');
                                    _loadTasks();
                                  } else if (value == 'delete') {
                                    await TaskManagerService()
                                        .deleteTask(task['task_id']);
                                    _loadTasks();
                                  } else if (value == 'edit') {
                                    // You can implement edit logic or open a new edit dialog
                                    print(
                                        "Edit tapped for task: ${task['task_id']}");
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                      value: 'edit', child: Text('Edit')),
                                  const PopupMenuItem(
                                      value: 'progress',
                                      child: Text('Move to In Progress')),
                                  const PopupMenuItem(
                                      value: 'completed',
                                      child: Text('Mark as Completed')),
                                  const PopupMenuItem(
                                      value: 'delete', child: Text('Delete')),
                                ],
                              ),
                            )
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class SidebarItem extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const SidebarItem({
    Key? key,
    required this.title,
    this.isSelected = false,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected
              ? const Color.fromARGB(255, 201, 210, 218)
              : Colors.black,
        ),
      ),
      onTap: onTap,
    );
  }
}

class TaskCard extends StatelessWidget {
  final String title;
  final String participant;
  final String dateAdded;
  final String priority;

  const TaskCard({
    Key? key,
    required this.title,
    required this.participant,
    required this.dateAdded,
    required this.priority,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 201, 210, 218),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6.0, vertical: 3.0),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(priority),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Text(priority,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 10)),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text("Participant: $participant",
                style: const TextStyle(fontSize: 11)),
            Text("Date added: $dateAdded",
                style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case "high":
        return Colors.red;
      case "medium":
        return Colors.orange;
      default:
        return Colors.green;
    }
  }
}
