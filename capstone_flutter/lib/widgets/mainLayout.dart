import 'package:capstone_flutter/widgets/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:capstone_flutter/widgets/topbar.dart';

class MainLayout extends StatelessWidget {
  final String selectedPage;
  final Widget child;
  final Function(String) onPageSelected;
  final Color backgroundColor;
  final Widget? topBar; // ✅ Optional topBar passed in
  final int? projectId;

  const MainLayout({
    Key? key,
    required this.selectedPage,
    required this.child,
    required this.onPageSelected,
    this.backgroundColor = const Color.fromARGB(255, 240, 241, 244),
    this.topBar,
    this.projectId,
  }) : super(key: key); // ✅ Clean constructor with no extra 'body'


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Row(
        children: [
          Sidebar(
            selectedPage: selectedPage,
            onPageSelected: onPageSelected,
          ),
          Expanded(
            child: Column(
              children: [
                topBar ?? TopBar(apiBaseUrl: 'http://127.0.0.1:8000', projectId:projectId! ),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
