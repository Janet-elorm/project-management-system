import 'package:flutter/material.dart';
import 'package:capstone_flutter/widgets/projectdata.dart';
import 'package:capstone_flutter/pages/progressTracker.dart';

class MiniSidebar extends StatefulWidget {
  final int selectedProjectId;
  final Function(int) onProjectSelected;

  const MiniSidebar({
    Key? key,
    required this.selectedProjectId,
    required this.onProjectSelected,
  }) : super(key: key);

  @override
  State<MiniSidebar> createState() => _MiniSidebarState();
}

class _MiniSidebarState extends State<MiniSidebar> {
  bool isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isCollapsed ? 0 : 200,
            constraints: const BoxConstraints(minHeight: 200),
            decoration: const BoxDecoration(
              color: Color(0xFFF0F2F5),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Visibility(
              visible: !isCollapsed,
              maintainState: true,
              maintainAnimation: true,
              maintainSize: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: const [
                        Icon(Icons.folder_copy, size: 18, color: Colors.blueGrey),
                        SizedBox(width: 8),
                        Text(
                          "My Projects",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: FutureBuilder<List<Project>>(
                      future: fetchProjects(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return const Center(child: Text("Error loading projects"));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text("No projects found"));
                        }

                        final projects = snapshot.data!;
                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: projects.length,
                          separatorBuilder: (_, __) => const Divider(height: 0),
                          itemBuilder: (context, index) {
                            final project = projects[index];
                            final isSelected = project.projectId == widget.selectedProjectId;
                            return Container(
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.blueGrey.shade100 : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: ListTile(
                                dense: true,
                                visualDensity: const VisualDensity(horizontal: 0, vertical: -3),
                                leading: Icon(Icons.folder_copy_outlined, size: 18, color: isSelected ? Colors.blueGrey : Colors.grey.shade600),
                                title: Text(
                                  project.title.isNotEmpty ? project.title : 'Untitled',
                                  style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () => widget.onProjectSelected(project.projectId),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 40,
            height: double.infinity,
            alignment: Alignment.topCenter,
            color: const Color(0xFFF0F2F5),
            child: IconButton(
              icon: const Icon(Icons.menu, size: 20),
              onPressed: () {
                setState(() => isCollapsed = !isCollapsed);
              },
              tooltip: isCollapsed ? 'Show Projects' : 'Hide Projects',
            ),
          ),
        ],
      ),
    );
  }
}
