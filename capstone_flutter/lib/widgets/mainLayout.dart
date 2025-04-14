import 'package:capstone_flutter/widgets/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:capstone_flutter/widgets/topbar.dart';

class MainLayout extends StatelessWidget {
  final String selectedPage;
  final Widget child;
  final Function(String) onPageSelected;
  final Color backgroundColor; 

  const MainLayout({
    Key? key,
    required this.selectedPage,
    required this.child,
    required this.onPageSelected,
    this.backgroundColor = Colors.white, 
  }) : super(key: key);

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
                const TopBar(),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
