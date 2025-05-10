import 'dart:async';

import 'package:flutter/material.dart';
import 'package:capstone_flutter/pages/taskManager.dart';
import 'package:capstone_flutter/widgets/profile.dart';
import 'package:capstone_flutter/widgets/projectdata.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:capstone_flutter/api_service/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  String get fullName => '$firstName $lastName';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class Task {
  final String id;
  final String title;
  final String? projectName;

  Task({
    required this.id,
    required this.title,
    this.projectName,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'].toString(),
      title: json['title'] ?? 'Untitled Task',
      projectName: json['project_name'],
    );
  }
}

sealed class SearchResult {
  const SearchResult();
}

class ProjectSearchResult extends SearchResult {
  final Project project;
  const ProjectSearchResult(this.project);
}

class TaskSearchResult extends SearchResult {
  final Task task;
  const TaskSearchResult(this.task);
}

class UserSearchResult extends SearchResult {
  final User user;
  const UserSearchResult(this.user);
}

class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

class TopBar extends StatefulWidget {
  final String apiBaseUrl;
  const TopBar({Key? key, required this.apiBaseUrl}) : super(key: key);

  @override
  _TopBarState createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  bool _notificationsViewed = false;
  List<Project> _projects = [];
  List<Task> _tasks = [];
  List<User> _users = [];
  String userName = "Loading...";
  String userEmail = "Loading...";
  String profileImage = 'https://via.placeholder.com/150';
  bool isLoading = true;
  bool isSearching = false;
  bool hasOverdue = false;
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final _searchDebounce = Debouncer(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchProjects();
    _fetchTasks();
    _fetchUsers();
    _checkOverdueTasks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _checkOverdueTasks() async {
    final notifications = await _fetchNotifications();
    final overdueTasks = notifications['overdue_tasks'] ?? [];
    setState(() {
      hasOverdue = overdueTasks.isNotEmpty;
      if (hasOverdue) _notificationsViewed = false;
    });
  }

  Future<Map<String, dynamic>> _fetchNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final response = await http.get(
        Uri.parse('${widget.apiBaseUrl}/dashboard/notifications'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to load notifications: ${response.body}');
        return {};
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      return {};
    }
  }

  void _showNotifications() async {
    final notifications = await _fetchNotifications();

    setState(() => _notificationsViewed = true);

    final overdueTasks = notifications['overdue_tasks'] ?? [];
    final dueTomorrow = notifications['reminders']?['due_tomorrow'] ?? [];
    final dueIn3Days = notifications['reminders']?['due_in_3_days'] ?? [];
    final dueIn7Days = notifications['reminders']?['due_in_7_days'] ?? [];
    final projectDeadlines = notifications['project_deadlines'] ?? [];

    final bool isAllEmpty = overdueTasks.isEmpty &&
        dueTomorrow.isEmpty &&
        dueIn3Days.isEmpty &&
        dueIn7Days.isEmpty &&
        projectDeadlines.isEmpty;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Notifications'),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: isAllEmpty
                  ? const Text('🎉 You have no notifications!',
                      style: TextStyle(color: Colors.grey))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (overdueTasks.isNotEmpty)
                          _buildSection('⚠️ Overdue Tasks', overdueTasks),
                        if (dueTomorrow.isNotEmpty)
                          _buildSection('📅 Due Tomorrow', dueTomorrow),
                        if (dueIn3Days.isNotEmpty)
                          _buildSection('📅 Due in 3 Days', dueIn3Days),
                        if (dueIn7Days.isNotEmpty)
                          _buildSection('📅 Due in 7 Days', dueIn7Days),
                        if (projectDeadlines.isNotEmpty)
                          _buildSection(
                              '🏁 Project Deadlines', projectDeadlines),
                      ],
                    ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNotificationIcon() {
    return Stack(
      children: [
        IconButton(
          onPressed: () async {
            _showNotifications(); // await is important so popup waits
            await _checkOverdueTasks(); // this updates badge after dialog closes
          },
          icon: const Icon(Icons.notifications),
        ),
        if (hasOverdue)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 12,
                minHeight: 12,
              ),
            ),
          ),
      ],
    );
  }

  Future<List<User>> _fetchUsers() async {
    try {
      final response =
          await http.get(Uri.parse('${widget.apiBaseUrl}/auth/users/'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      }
      throw Exception('Failed to load users');
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  Future<List<Task>> _fetchTasks() async {
    try {
      final response =
          await http.get(Uri.parse('${widget.apiBaseUrl}/dashboard/tasks'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Task.fromJson(json)).toList();
      }
      throw Exception('Failed to load tasks');
    } catch (e) {
      print('Error fetching tasks: $e');
      return [];
    }
  }

  Future<void> _fetchProjects() async {
    try {
      final projects = await fetchProjects();
      setState(() => _projects = projects);
    } catch (e) {
      print("Failed to fetch projects: $e");
    }
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _authService.getCurrentUser();
      if (userData != null) {
        setState(() {
          userName = '${userData['first_name']} ${userData['last_name']}';
          userEmail = userData['email'] ?? "No email";
          profileImage =
              userData['profile_picture'] ?? 'https://via.placeholder.com/150';
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading user data: $e");
      setState(() => isLoading = false);
    }
  }

  Future<Iterable<SearchResult>> _performSearch(String query) async {
    if (query.isEmpty) return const Iterable.empty();

    setState(() => isSearching = true);
    final lowerQuery = query.toLowerCase();
    final results = <SearchResult>[];

    try {
      // Search projects
      results.addAll(_projects
          .where((project) => project.title.toLowerCase().contains(lowerQuery))
          .map((project) => ProjectSearchResult(project)));

      // Search users
      final users = await _fetchUsers();
      results.addAll(users
          .where((user) =>
              user.fullName.toLowerCase().contains(lowerQuery) ||
              user.email.toLowerCase().contains(lowerQuery))
          .map((user) => UserSearchResult(user)));

      // Search tasks
      final tasks = await _fetchTasks();
      results.addAll(tasks
          .where((task) =>
              task.title.toLowerCase().contains(lowerQuery) ||
              (task.projectName?.toLowerCase().contains(lowerQuery) ?? false))
          .map((task) => TaskSearchResult(task)));
    } catch (e) {
      print('Search error: $e');
    } finally {
      setState(() => isSearching = false);
    }

    return results;
  }

  void _navigateToProfilePage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ProfilePage()));
  }

  Future<void> _signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  Widget _buildSection(String title, List<dynamic> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        if (items.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child:
                Text('🎉 No items here!', style: TextStyle(color: Colors.grey)),
          )
        else
          ...items.map<Widget>((item) {
            final dueDate = item['due_date']?.substring(0, 10) ?? 'No date';
            return ListTile(
              title: Text(item['title'] ?? 'Untitled'),
              subtitle: Text('Due: $dueDate'),
              dense: true,
            );
          }).toList(),
      ],
    );
  }

  IconData _getIconForResult(SearchResult result) {
    return switch (result) {
      ProjectSearchResult() => Icons.folder,
      TaskSearchResult() => Icons.task,
      UserSearchResult() => Icons.person,
    };
  }

  String _getTitleForResult(SearchResult result) {
    return switch (result) {
      ProjectSearchResult(project: final project) => project.title,
      TaskSearchResult(task: final task) => task.title,
      UserSearchResult(user: final user) => user.fullName,
    };
  }

  String? _getSubtitleForResult(SearchResult result) {
    return switch (result) {
      ProjectSearchResult() => 'Project',
      TaskSearchResult(task: final task) => task.projectName,
      UserSearchResult(user: final user) => user.email,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
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
          // Universal Search Bar
          SizedBox(
            width: 800,
            child: Autocomplete<SearchResult>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<SearchResult>.empty();
                }

                final completer = Completer<Iterable<SearchResult>>();
                _searchDebounce.run(() async {
                  final results = await _performSearch(textEditingValue.text);
                  if (!completer.isCompleted) {
                    completer.complete(results);
                  }
                });

                return completer.future;
              },
              onSelected: (SearchResult selection) {
                switch (selection) {
                  case ProjectSearchResult(project: final project):
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TaskManagerPage(projectId: project.projectId),
                      ),
                    );
                  case TaskSearchResult():
                    // Handle task selection
                    break;
                  case UserSearchResult():
                    // Handle user selection
                    break;
                }
              },
              fieldViewBuilder: (
                BuildContext context,
                TextEditingController controller,
                FocusNode focusNode,
                VoidCallback onFieldSubmitted,
              ) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    hintText: "Search projects, tasks...",
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: isSearching
                        ? const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : null,
                  ),
                );
              },
              optionsViewBuilder: (
                BuildContext context,
                AutocompleteOnSelected<SearchResult> onSelected,
                Iterable<SearchResult> options,
              ) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 160),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          final result = options.elementAt(index);
                          return ListTile(
                            leading: Icon(_getIconForResult(result)),
                            title: Text(_getTitleForResult(result)),
                            subtitle: Text(_getSubtitleForResult(result) ?? ''),
                            onTap: () => onSelected(result),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Profile Section
          Row(
            children: [
              _buildNotificationIcon(),
              const SizedBox(width: 16),
              isLoading
                  ? const CircularProgressIndicator()
                  : PopupMenuButton<int>(
                      offset: const Offset(0, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem<int>(
                          value: 0,
                          enabled: false,
                          child: Column(
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(profileImage),
                                radius: 25,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                userEmail,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        PopupMenuItem<int>(
                          value: 1,
                          child: ListTile(
                            leading: const Icon(Icons.settings),
                            title: const Text("Manage Account"),
                            onTap: () {
                              Navigator.pop(context);
                              _navigateToProfilePage();
                            },
                          ),
                        ),
                        PopupMenuItem<int>(
                          value: 2,
                          child: ListTile(
                            leading: const Icon(Icons.logout),
                            title: const Text("Sign Out"),
                            onTap: () {
                              Navigator.pop(context);
                              _signOut();
                            },
                          ),
                        ),
                      ],
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(profileImage),
                            radius: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
