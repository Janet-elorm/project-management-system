import 'package:flutter/material.dart';

class TopBar extends StatefulWidget {
  const TopBar({Key? key}) : super(key: key);

  @override
  _TopBarState createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  String userName = "John Doe";
  String userEmail = "john.doe@gmail.com";
  String profileImage = 'https://via.placeholder.com/150';

  void _navigateToProfilePage() {
    // TODO: Implement navigation to Profile Page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage()), // Replace with actual profile page
    );
  }

  void _signOut() {
    // TODO: Implement sign-out functionality
    print("User signed out");
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
          // Search Bar
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
              PopupMenuButton<int>(
                offset: const Offset(0, 50), // Position the dropdown below
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                itemBuilder: (context) => [
                  // Profile Info (Non-clickable)
                  PopupMenuItem<int>(
                    value: 0,
                    enabled: false, // Make it non-clickable
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
                  // Manage Account
                  PopupMenuItem<int>(
                    value: 1,
                    child: ListTile(
                      leading: const Icon(Icons.settings),
                      title: const Text("Manage Account"),
                      onTap: () {
                        Navigator.pop(context); // Close dropdown
                        _navigateToProfilePage(); // Navigate to Profile Page
                      },
                    ),
                  ),
                  // Sign Out
                  PopupMenuItem<int>(
                    value: 2,
                    child: ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text("Sign Out"),
                      onTap: () {
                        Navigator.pop(context); // Close dropdown
                        _signOut(); // Handle sign-out
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

// Dummy Profile Page
class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile Page")),
      body: const Center(child: Text("User Profile Settings Here")),
    );
  }
}

