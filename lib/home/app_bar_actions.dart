import 'package:badges/badges.dart' as badges;
import 'package:culinect/chat/messages_screen.dart';
import 'package:culinect/screens/notifications_screen.dart';
import 'package:culinect/user/UserProfile_Screen.dart';
import 'package:culinect/user/users.dart';
import 'package:culinect/widgets/notification_icon.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

List<Widget> buildAppBarActions(
    BuildContext context, User user, Function toggleTheme) {
  return [
    IconButton(
      icon: const Icon(Icons.search, color: Colors.blue),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const UsersScreen()),
      ),
    ),
    IconButton(
      icon: const badges.Badge(
        child: NotificationIcon(type: 'notification'),
      ),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NotificationsScreen()),
      ),
    ),
    IconButton(
      icon: const badges.Badge(
        child: Icon(Icons.message, color: Colors.blue),
      ),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MessagesScreen()),
      ),
    ),
    _buildProfileAvatar(context, user),
    _buildSettingsMenu(context, user, toggleTheme),
  ];
}

Widget _buildProfileAvatar(BuildContext context, User user) {
  return GestureDetector(
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(userId: user.uid),
      ),
    ),
    child: CircleAvatar(
      radius: 16,
      backgroundImage: user.photoURL != null
          ? NetworkImage(user.photoURL!)
          : const AssetImage('assets/images/default_profile_image.png')
              as ImageProvider<Object>,
    ),
  );
}

Widget _buildSettingsMenu(
    BuildContext context, User user, Function toggleTheme) {
  return PopupMenuButton<String>(
    onSelected: (value) =>
        _handleMenuSelection(context, value, user, toggleTheme),
    itemBuilder: (BuildContext context) => const [
      PopupMenuItem(value: 'settings', child: Text('Profile')),
      PopupMenuItem(value: 'toggleTheme', child: Text('Toggle Theme')),
      PopupMenuItem(value: 'logout', child: Text('Logout')),
    ],
  );
}

void _handleMenuSelection(
    BuildContext context, String value, User user, Function toggleTheme) {
  switch (value) {
    case 'settings':
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserProfileScreen(userId: user.uid),
        ),
      );
      break;
    case 'toggleTheme':
      toggleTheme();
      break;
    case 'logout':
      FirebaseAuth.instance.signOut();
      break;
  }
}
