import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:culinect/home/app_bar_actions.dart';
import 'package:culinect/home/create_drawer.dart';
import 'package:culinect/home/large_screen_layout.dart';
import 'package:culinect/home/small_screen_layout.dart';
import 'package:culinect/screens/job_feed_screen.dart';
import 'package:culinect/screens/post_feed_screen.dart';
import 'package:culinect/screens/recipe_feed_screen.dart';
import 'package:culinect/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../create/job_create.dart';
import '../create/post_create.dart';
import '../create/recipe_create.dart';

bool isLightTheme = true; // Define theme state globally

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late User _user; // Stores the authenticated user
  int _selectedIndex = 0; // Navigation selection index
  bool _isRailExpanded = false; // Tracks rail expansion state

  StreamSubscription<QuerySnapshot>? _messageSubscription;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _listenToUnreadMessages();
  }

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (mounted) {
        setState(() {
          _user = user;
        });
      }
    }
  }

  void _listenToUnreadMessages() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _messageSubscription = FirebaseFirestore.instance
          .collection('messages')
          .where('receiverId', isEqualTo: user.uid)
          .where('isRead', isEqualTo: false)
          .snapshots()
          .listen((snapshot) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  void _toggleTheme() {
    if (mounted) {
      setState(() {
        isLightTheme = !isLightTheme;
      });
    }
  }

  Widget _buildLargeScreenNavRail() {
    return NavigationRail(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) {
        if (mounted) {
          setState(() {
            _selectedIndex = index;
          });
        }
      },
      extended: _isRailExpanded,
      leading: IconButton(
        icon: Icon(
          _isRailExpanded ? Icons.chevron_left : Icons.chevron_right,
        ),
        onPressed: () {
          if (mounted) {
            setState(() {
              _isRailExpanded = !_isRailExpanded;
            });
          }
        },
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
          icon: Icon(Icons.message),
          label: Text('Messages'),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 4.0,
      color: isLightTheme
          ? AppTheme.lightTheme.bottomAppBarTheme.color
          : AppTheme.darkTheme.bottomAppBarTheme.color,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBottomNavItem(Icons.home, 0),
          _buildBottomNavItem(Icons.work, 1),
          _buildBottomNavItem(Icons.restaurant_menu, 2),
          _buildBottomNavItem(Icons.article, 3),
          _buildBottomNavItem(Icons.quiz, 4),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, int index) {
    return IconButton(
      icon: Icon(icon, color: Colors.blue),
      onPressed: () {
        if (mounted) {
          setState(() {
            _selectedIndex = index;
          });
        }
      },
    );
  }

  Widget _buildBodyContent() {
    switch (_selectedIndex) {
      case 1:
        return const JobFeedScreen();
      case 2:
        return const RecipeFeedScreen();
      default:
        return const PostFeedScreen();
    }
  }

  void _showCreateDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.48,
          child: Container(
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
                _createDrawerOption(
                  context: context,
                  icon: Icons.update,
                  color: Colors.blue,
                  label: 'Post an Update',
                  widget: const CreatePostScreen(),
                ),
                _createDrawerOption(
                  context: context,
                  icon: Icons.restaurant_menu,
                  color: Colors.orange,
                  label: 'Share a New Recipe',
                  widget: const RecipeCreateScreen(),
                ),
                _createDrawerOption(
                  context: context,
                  icon: Icons.work,
                  color: Colors.green,
                  label: 'Announce a Job Opening',
                  widget: const CreateJobScreen(),
                ),
                _createDrawerOption(
                  context: context,
                  icon: Icons.article,
                  color: Colors.purple,
                  label: 'Publish a Blog Post',
                  widget:
                      Container(), // Placeholder for Blog Post functionality
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _createDrawerOption({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String label,
    required Widget widget,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(color: isLightTheme ? Colors.black : Colors.white),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => widget),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLargeScreen = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CuliNect',
          style: TextStyle(fontSize: 20.0, color: Colors.blue),
        ),
        actions: buildAppBarActions(context, _user, _toggleTheme),
        backgroundColor: isLightTheme
            ? AppTheme.lightTheme.primaryColor
            : AppTheme.darkTheme.primaryColor,
      ),
      body: isLargeScreen
          ? LargeScreenLayout(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              bodyContent: _buildBodyContent(),
              largeScreenNavRail: _buildLargeScreenNavRail(),
              floatingActionButton: FloatingActionButton(
                onPressed: _showCreateDrawer,
                backgroundColor: isLightTheme
                    ? AppTheme.lightTheme.primaryColor
                    : AppTheme.darkTheme.primaryColor,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            )
          : SmallScreenLayout(
              selectedIndex: _selectedIndex,
              onBottomNavItemSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              bodyContent: _buildBodyContent(),
              bottomNavBar: _buildBottomNavBar(),
              floatingActionButton: FloatingActionButton(
                onPressed: _showCreateDrawer,
                backgroundColor: isLightTheme
                    ? AppTheme.lightTheme.primaryColor
                    : AppTheme.darkTheme.primaryColor,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
      drawer: buildCreateDrawer(context, isLightTheme),
    );
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }
}
