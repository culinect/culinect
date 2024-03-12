import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'theme/theme.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

bool isLightTheme = true; // Define the variable at the top level

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late User _user; // Variable to store the signed-in user data

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
                    // Add functionality for search icon
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
                  },
                ),
                CircleAvatar(
                  radius: 16,
                  backgroundImage: _user.photoURL != null
                      ? NetworkImage(_user.photoURL!)
                      : const AssetImage('assets/images/default_profile_image.png') as ImageProvider<Object>,
                ),
                PopupMenuButton<String>(
                  onSelected: (String value) {
                    // Handle menu item selection
                    switch (value) {
                      case 'settings':
                      // Open profile screen when settings option is clicked
                        Navigator.push(
                          context,
                          MaterialPageRoute<ProfileScreen>(
                            builder: (context) => ProfileScreen(
                              appBar: AppBar(
                                title: const Text('User Profile'),
                              ),
                              actions: [
                                SignedOutAction((context) {
                                  Navigator.of(context).pop();
                                })
                              ],
                              children: [
                                const Divider(),
                                Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: Image.asset('assets/images/chef.jpeg'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                        break;
                      case 'switch_theme':
                      // Handle switch theme option
                        toggleTheme();
                        break;
                      case 'logout':
                      // Handle logout option
                        FirebaseAuth.instance.signOut();
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
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
              backgroundColor: isLightTheme ? AppTheme.lightTheme.primaryColor : AppTheme.darkTheme.primaryColor,
            ),
            body: const Center(
              child: Text(
                'Home Screen Content',
                style: TextStyle(fontSize: 24.0),
              ),
            ),
            bottomNavigationBar: BottomAppBar(
              elevation: 0, // Remove elevation
              color: AppTheme.lightTheme.bottomAppBarTheme.color, // Apply bottom app bar color from the theme
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.home),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.work),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.restaurant_menu),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.article),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.quiz_sharp),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_box_sharp), // Floating action button icon
                    onPressed: () {
                      // Add functionality for the floating action button
                    },
                  ),
                ],
              ),

            ),

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
                    // Add functionality for search icon
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
                  },
                ),
                PopupMenuButton<String>(
                  onSelected: (String value) {
                    // Handle menu item selection
                    switch (value) {
                      case 'settings':
                      // Open profile screen when settings option is clicked
                        Navigator.push(
                          context,
                          MaterialPageRoute<ProfileScreen>(
                            builder: (context) => ProfileScreen(
                              appBar: AppBar(
                                title: const Text('User Settings'),
                              ),
                              actions: [
                                SignedOutAction((context) {
                                  Navigator.of(context).pop();
                                })
                              ],
                              children: [
                                const Divider(),
                                Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: Image.asset('assets/images/chef.jpeg'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                        break;
                      case 'switch_theme':
                      // Handle switch theme option
                        toggleTheme();
                        break;
                      case 'logout':
                      // Handle logout option
                        FirebaseAuth.instance.signOut();
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
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
              backgroundColor: isLightTheme ? AppTheme.lightTheme.primaryColor : AppTheme.darkTheme.primaryColor,
            ),
            body: const Center(
              child: Text(
                'Home Screen Content',
                style: TextStyle(fontSize: 24.0),
              ),
            ),
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: const BoxDecoration(
                      color: Colors.deepOrange,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: _user.photoURL != null
                              ? NetworkImage(_user.photoURL!)
                              : const AssetImage('assets/images/default_profile_image.png') as ImageProvider<Object>,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _user != null ? _user.displayName ?? 'Anonymous' : 'Anonymous', // Add user name
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),

                  ),
                  ListTile(
                    leading: const Icon(Icons.home),
                    title: const Text('Home'),
                    onTap: () {
                      // Handle Home navigation
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.work),
                    title: const Text('Jobs'),
                    onTap: () {
                      // Handle Work navigation
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.restaurant_menu),
                    title: const Text('Recipes'),
                    onTap: () {
                      // Handle Restaurant Menu navigation
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.article),
                    title: const Text('Blogs'),
                    onTap: () {
                      // Handle Article navigation
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.quiz),
                    title: const Text('Quiz'),
                    onTap: () {
                      // Handle Quiz navigation
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.add_box_sharp), // Floating action button icon
                    title: const Text('Create'), // Text for floating action button
                    onTap: () {
                      // Add functionality for the floating action button
                    },
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}

void main() {
  runApp( MaterialApp(
    home: const HomeScreen(),
    theme: isLightTheme ? AppTheme.lightTheme : AppTheme.darkTheme,
  ));
}
