import 'package:culinect/home/create_drawer.dart';
import 'package:flutter/material.dart';

class SmallScreenLayout extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onBottomNavItemSelected;
  final Widget bodyContent;
  final Widget bottomNavBar;
  final Widget floatingActionButton;

  const SmallScreenLayout({
    Key? key,
    required this.selectedIndex,
    required this.onBottomNavItemSelected,
    required this.bodyContent,
    required this.bottomNavBar,
    required this.floatingActionButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: bodyContent,
      bottomNavigationBar: bottomNavBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      drawer: buildCreateDrawer(context, true), // Adjust the theme as required
    );
  }
}
