import 'package:capstone_flutter/auth/login.dart';
import 'package:capstone_flutter/pages/dashboard.dart';
import 'package:capstone_flutter/pages/taskManager.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        textTheme: GoogleFonts.merriweatherTextTheme(),
      ),
      initialRoute: '/',
      routes: {
       '/': (context) => LoginPage(),
      //'/': (context) => DashboardPage(),
        // Remove the direct route to TaskManagerPage since it needs arguments
      },
      onGenerateRoute: (settings) {
        // Handle all your routes here
        if (settings.name == '/taskManager') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => TaskManagerPage(
              projectId: args['projectId'],
            ),
          );
        }
        return MaterialPageRoute(
         builder: (context) => LoginPage(),
         //builder: (context) => DashboardPage(),
        );
      },
    );
  }
}
