// import 'package:flutter/material.dart';

// class UpcomingDeadlinesSection extends StatelessWidget {
//   final List<dynamic> deadlines;

//   const UpcomingDeadlinesSection({super.key, required this.deadlines});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Upcoming Deadlines',
//           style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 8),
//         Card(
//           elevation: 3,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           color: Colors.white,
//           child: SizedBox(
//             height: 240, // adjust based on space
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//               child: deadlines.isEmpty
//                   ? const Center(
//                       child: Text(
//                         "No upcoming deadlines.",
//                         style: TextStyle(fontSize: 12, color: Colors.grey),
//                       ),
//                     )
//                   : ListView.separated(
//                       itemCount: deadlines.length,
//                       separatorBuilder: (context, index) => Divider(height: 16),
//                       itemBuilder: (context, index) {
//                         final task = deadlines[index];
//                         return Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             // Task title and project/category
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     task['title'] ?? 'Untitled Task',
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.w600,
//                                       fontSize: 13,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Text(
//                                     "In ${task['category']} • Priority: ${task['priority']}",
//                                     style: TextStyle(
//                                       fontSize: 11,
//                                       color: Colors.grey.shade600,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             const SizedBox(width: 10),
//                             // Due date
//                             Text(
//                               _formatDate(task['due_date']),
//                               style: const TextStyle(
//                                 fontSize: 11,
//                                 fontWeight: FontWeight.w500,
//                                 color: Color.fromARGB(255, 148, 87, 235), // Purple tint
//                               ),
//                             ),
//                           ],
//                         );
//                       },
//                     ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   String _formatDate(String? isoDate) {
//     if (isoDate == null) return "N/A";
//     final date = DateTime.tryParse(isoDate);
//     if (date == null) return isoDate;
//     return "${date.day}/${date.month}/${date.year}";
//   }
// }

import 'package:flutter/material.dart';

class UpcomingDeadlinesSection extends StatelessWidget {
  // Static data for now
  final List<dynamic> deadlines = [
    {
      'title': 'Design Homepage',
      'category': 'To Do',
      'due_date': '2025-04-12',
      'priority': 'High',
    },
    {
      'title': 'Develop Backend API',
      'category': 'In Progress',
      'due_date': '2025-04-15',
      'priority': 'Medium',
    },
    {
      'title': 'Prepare Presentation',
      'category': 'Completed',
      'due_date': '2025-04-10',
      'priority': 'Low',
    },
    {
      'title': 'Prepare Presentation',
      'category': 'Completed',
      'due_date': '2025-04-10',
      'priority': 'Low',
    },
    {
      'title': 'Prepare Presentation',
      'category': 'Completed',
      'due_date': '2025-04-10',
      'priority': 'Low',
    },
  ];

   UpcomingDeadlinesSection({super.key, required List deadlines});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upcoming Deadlines',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: Colors.white,
          child: SizedBox(
            height: 240, // adjust based on space
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: deadlines.isEmpty
                  ? const Center(
                      child: Text(
                        "No upcoming deadlines.",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    )
                  : ListView.separated(
                      itemCount: deadlines.length,
                      separatorBuilder: (context, index) => Divider(height: 16),
                      itemBuilder: (context, index) {
                        final task = deadlines[index];
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Task title and project/category
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task['title'] ?? 'Untitled Task',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "In ${task['category']} • Priority: ${task['priority']}",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Due date
                            Text(
                              _formatDate(task['due_date']),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.blue // Purple tint
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return "N/A";
    final date = DateTime.tryParse(isoDate);
    if (date == null) return isoDate;
    return "${date.day}/${date.month}/${date.year}";
  }
}
