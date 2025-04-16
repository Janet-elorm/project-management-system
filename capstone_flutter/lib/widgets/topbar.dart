import 'package:capstone_flutter/widgets/profile.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:capstone_flutter/api_service/auth_service.dart';

class TopBar extends StatefulWidget {
  const TopBar({Key? key}) : super(key: key);

  @override
  _TopBarState createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  String userName = "Loading...";
  String userEmail = "Loading...";
  String profileImage = 'https://via.placeholder.com/150';
  bool isLoading = true;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _authService.getCurrentUser();
      if (userData != null) {
        setState(() {
          userName = '${userData['first_name']} ${userData['last_name']}';
          userEmail = userData['email'] ?? "No email";
          profileImage = userData['profile_picture'] ?? 'https://via.placeholder.com/150';
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading user data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _navigateToProfilePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage()),
    );
  }

  Future<void> _signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      // Navigate to login page or root
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      print("Error signing out: $e");
    }
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
          // Search Bar (unchanged)
          SizedBox(
            width: 800,
            height: 35,
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search",
                hintStyle: const TextStyle(fontSize: 14),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: const BorderSide(
                      color: Color.fromARGB(255, 209, 209, 209)),
                ),
              ),
            ),
          ),
          // Notification Icon and Profile Dropdown
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications),
              ),
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

