import 'package:capstone_flutter/api_service/task_manager_service.dart';
import 'package:capstone_flutter/pages/dashboard.dart';
import 'package:capstone_flutter/pages/progressTracker.dart';
import 'package:capstone_flutter/pages/projects.dart';
import 'package:capstone_flutter/widgets/addTaskDialog.dart';
import 'package:capstone_flutter/widgets/mini_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:capstone_flutter/widgets/mainLayout.dart';

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
    return MainLayout(
      selectedPage: selectedPage,
      onPageSelected: (page) {
        if (page == "Dashboard") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    DashboardPage(projectId: widget.projectId)),
          );
        } else if (page == "Progress Tracker") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ProgressTrackingPage(projectId: widget.projectId)),
          );
        } else if (page == "Projects") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ProjectsPage(projectId: widget.projectId)),
          );
        } else if (page == "Task Manager") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    TaskManagerPage(projectId: widget.projectId)),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MiniSidebar(
              selectedProjectId: widget.projectId,
              onProjectSelected: (projectId) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaskManagerPage(projectId: projectId),
                  ),
                );
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
                  _buildTaskBoard(),
                ],
              ),
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
        color: const Color.fromARGB(255, 245, 246, 249),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            projectData?['title'] ?? "Project Title",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  "Start Date: ${projectData?['start_date'] ?? 'N/A'}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              Expanded(
                child: Text(
                  "Deadline: ${projectData?['deadline'] ?? 'N/A'}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Description: ${projectData?['project_description'] ?? 'No description available.'}",
            style: const TextStyle(fontSize: 13),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskColumn(String category) {
    final filteredTasks =
        tasks.where((task) => task['category'] == category).toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                category,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AddTaskDialog(
                      projectId: widget.projectId,
                      category: category,
                      onTaskAdded: _loadTasks,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filteredTasks.isEmpty
                ? const Center(child: Text("No tasks"))
                : ListView.builder(
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      return Card(
                        color: const Color.fromARGB(255, 245, 246, 249),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(task['title'] ?? 'Untitled Task',
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w500)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Assigned to: ${task['assigned_to'] ?? 'Unassigned'}",
                                style: const TextStyle(fontSize: 11),
                              ),
                              Text(
                                "Priority: ${task['priority'] ?? 'Medium'}",
                                style: const TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'progress') {
                                await _updateCategory(
                                    task['task_id'], 'In Progress');
                              } else if (value == 'completed') {
                                await _updateCategory(
                                    task['task_id'], 'Completed');
                              } else if (value == 'delete') {
                                await _deleteTask(task['task_id']);
                              }
                            },
                            itemBuilder: (context) => [
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
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

Widget _buildTaskBoard() {
  return Expanded(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildTaskCard("To Do")),
        const SizedBox(width: 16),
        Expanded(child: _buildTaskCard("In Progress")),
        const SizedBox(width: 16),
        Expanded(child: _buildTaskCard("Completed")),
      ],
    ),
  );
}

  Widget _buildTaskCard(String category) {
    final filteredTasks =
        tasks.where((task) => task['category'] == category).toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 245, 246, 249),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                category,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add, size: 20),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AddTaskDialog(
                      projectId: widget.projectId,
                      category: category,
                      onTaskAdded: _loadTasks,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filteredTasks.isEmpty
                ? const Center(child: Text("No tasks in this category"))
                : ListView.separated(
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      return Card(
                        color: const Color.fromARGB(255, 245, 246, 249),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          title: Text(
                            task['title'] ?? 'Untitled Task',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                "Assigned: ${task['assigned_to'] ?? 'Unassigned'}",
                                style: const TextStyle(fontSize: 10),
                              ),
                              Text(
                                "Priority: ${task['priority'] ?? 'Medium'}",
                                style: const TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, size: 20),
                            onSelected: (value) async {
                              if (value == 'progress') {
                                await _updateCategory(
                                    task['task_id'], 'In Progress');
                              } else if (value == 'completed') {
                                await _updateCategory(
                                    task['task_id'], 'Completed');
                              } else if (value == 'delete') {
                                await _deleteTask(task['task_id']);
                              } else if (value == 'edit') {
                                // Implement your edit dialog later
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
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
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
