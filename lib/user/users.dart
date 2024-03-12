import 'package:flutter/material.dart';

import 'UserProfile_Screen.dart';

class UsersScreen extends StatelessWidget {
  // Dummy data for users
  final List<String> users = ['User 1', 'User 2', 'User 3', 'User 4'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Users'),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(users[index]),
            onTap: () {
              // Navigate to UserProfileScreen when a user is tapped
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfileScreen(userId: users[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
