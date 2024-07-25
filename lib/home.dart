import 'package:culinect/create/job_create.dart';
import 'package:culinect/create/post_create.dart';
import 'package:culinect/create/recipe_create.dart';
import 'package:culinect/screens/job_feed_screen.dart';
import 'package:culinect/screens/post_feed_screen.dart';
import 'package:culinect/screens/recipe_feed_screen.dart';
import 'package:culinect/theme/theme.dart';
import 'package:culinect/user/UserProfile_Screen.dart';
import 'package:culinect/user/users.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

import 'chat/messages_screen.dart';

bool isLightTheme = true; // Define the variable at the top level

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late User _user; // Variable to store the signed-in user data
  int _selectedIndex = 0; // Index of the selected navigation item
  bool _isRailExpanded = false; // Variable to track navigation rail state

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load user data when the screen initializes
  }

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _user = user;
      });
    }
  }

  void toggleTheme() {
    setState(() {
      isLightTheme = !isLightTheme;
    });
  }

  void _openCreateDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.48, // Set height to 48% of the screen height
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            decoration: BoxDecoration(
              color: isLightTheme ? Colors.white54 : Colors.grey[400],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25.0),
                topRight: Radius.circular(25.0),
              ),
            ),
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    'Showcase Your Culinary Talent to the World',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                      color: isLightTheme ? Colors.black : Colors.white,
                    ),
                  ),
                ),
                const Divider(thickness: 2),
                ListTile(
                  leading: Icon(Icons.update,
                      color: isLightTheme ? Colors.black : Colors.white),
                  title: Text(
                    'Post an Update',
                    style: TextStyle(
                        color: isLightTheme ? Colors.black : Colors.white),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreatePostScreen(),
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Icon(Icons.restaurant_menu,
                      color: isLightTheme ? Colors.black : Colors.white),
                  title: Text(
                    'Share a New Recipe',
                    style: TextStyle(
                        color: isLightTheme ? Colors.black : Colors.white),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RecipeCreateScreen(),
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Icon(Icons.work,
                      color: isLightTheme ? Colors.black : Colors.white),
                  title: Text(
                    'Announce a Job Opening',
                    style: TextStyle(
                        color: isLightTheme ? Colors.black : Colors.white),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateJobScreen(),
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Icon(Icons.article,
                      color: isLightTheme ? Colors.black : Colors.white),
                  title: Text(
                    'Publish a Blog Post',
                    style: TextStyle(
                        color: isLightTheme ? Colors.black : Colors.white),
                  ),
                  onTap: () {
                    // Handle Publish a Blog Post action
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLargeScreen = MediaQuery.of(context).size.width >= 600;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          // Show BottomAppBar for smaller screens
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'CuliNect',
                style: TextStyle(
                  fontFamily: 'NunitoSans',
                  fontSize: 20.0,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UsersScreen(),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () {
                    // Add functionality for notifications icon
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.message),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MessagesScreen(),
                      ),
                    );
                    // Add functionality for message icon
                  },
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserProfileScreen(
                          userId: _user.uid,
                        ),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 16,
                    backgroundImage: _user.photoURL != null
                        ? NetworkImage(_user.photoURL!)
                        : const AssetImage(
                                'assets/images/default_profile_image.png')
                            as ImageProvider<Object>,
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (String value) {
                    switch (value) {
                      case 'settings':
                        Navigator.push(
                          context,
                          MaterialPageRoute<ProfileScreen>(
                            builder: (context) => UserProfileScreen(
                              userId: _user.uid,
                            ),
                          ),
                        );
                        break;
                      case 'switch_theme':
                        toggleTheme();
                        break;
                      case 'logout':
                        FirebaseAuth.instance.signOut();
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'settings',
                      child: ListTile(
                        leading: Icon(Icons.settings),
                        title: Text('Settings'),
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'switch_theme',
                      child: ListTile(
                        leading: Icon(Icons.color_lens),
                        title: Text('Switch Theme'),
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: ListTile(
                        leading: Icon(Icons.logout),
                        title: Text('Logout'),
                      ),
                    ),
                  ],
                ),
              ],
              centerTitle: false,
              backgroundColor: isLightTheme
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.darkTheme.primaryColor,
            ),
            body: _selectedIndex == 0
                ? const PostFeedScreen()
                : _selectedIndex == 1
                    ? const JobFeedScreen()
                    : _selectedIndex == 2
                        ? const RecipeFeedScreen() // Show RecipeFeedScreen for Recipe Feed
                        : _selectedIndex == 3
                            ? const UsersScreen()
                            : const PostFeedScreen(),
            bottomNavigationBar: BottomAppBar(
              shape: const CircularNotchedRectangle(),
              notchMargin: 4.0,
              elevation: 0,
              color: isLightTheme
                  ? AppTheme.lightTheme.bottomAppBarTheme.color
                  : AppTheme.darkTheme.bottomAppBarTheme.color,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.home),
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 0;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.work),
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 1;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.restaurant_menu),
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 2;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.article),
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 3;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.quiz_sharp),
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 4;
                      });
                    },
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: _openCreateDrawer,
              backgroundColor: isLightTheme
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.darkTheme.primaryColor,
              shape: const CircleBorder(),
              child: const Icon(Icons.add),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.endDocked,
          );
        } else {
          // Show Drawer for larger screens
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'CuliNect',
                style: TextStyle(
                  fontFamily: 'NunitoSans',
                  fontSize: 20.0,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UsersScreen(),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () {
                    // Add functionality for notifications icon
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.message),
                  onPressed: () {
                    // Add functionality for message icon
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MessagesScreen(),
                      ),
                    );
                  },
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserProfileScreen(
                          userId: _user.uid,
                        ),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 16,
                    backgroundImage: _user.photoURL != null
                        ? NetworkImage(_user.photoURL!)
                        : const AssetImage(
                                'assets/images/default_profile_image.png')
                            as ImageProvider<Object>,
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (String value) {
                    switch (value) {
                      case 'settings':
                        Navigator.push(
                          context,
                          MaterialPageRoute<ProfileScreen>(
                            builder: (context) => UserProfileScreen(
                              userId: _user.uid,
                            ),
                          ),
                        );
                        break;
                      case 'switch_theme':
                        toggleTheme();
                        break;
                      case 'logout':
                        FirebaseAuth.instance.signOut();
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'settings',
                      child: ListTile(
                        leading: Icon(Icons.settings),
                        title: Text('Settings'),
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'switch_theme',
                      child: ListTile(
                        leading: Icon(Icons.color_lens),
                        title: Text('Switch Theme'),
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: ListTile(
                        leading: Icon(Icons.logout),
                        title: Text('Logout'),
                      ),
                    ),
                  ],
                ),
              ],
              centerTitle: false,
              backgroundColor: isLightTheme
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.darkTheme.primaryColor,
            ),
            body: Row(
              children: [
                NavigationRail(
                  extended: _isRailExpanded,
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (int index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  leading: Column(
                    children: [
                      IconButton(
                        icon: Icon(
                            _isRailExpanded ? Icons.arrow_back : Icons.menu),
                        onPressed: () {
                          setState(() {
                            _isRailExpanded = !_isRailExpanded;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      FloatingActionButton(
                        onPressed: _openCreateDrawer,
                        backgroundColor: isLightTheme
                            ? AppTheme.lightTheme.primaryColor
                            : AppTheme.darkTheme.primaryColor,
                        shape: const CircleBorder(),
                        child: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.work),
                      label: Text('Jobs'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.restaurant_menu),
                      label: Text('Recipes'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.article),
                      label: Text('Blogs'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.quiz_sharp),
                      label: Text('Quiz'),
                    ),
                  ],
                ),
                Expanded(
                  child: _selectedIndex == 0
                      ? const PostFeedScreen()
                      : _selectedIndex == 1
                          ? const JobFeedScreen()
                          : _selectedIndex == 2
                              ? const RecipeFeedScreen()
                              : _selectedIndex == 3
                                  ? const UsersScreen()
                                  : const PostFeedScreen(),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
