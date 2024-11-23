import 'package:culinect/home/create_drawer.dart';
import 'package:culinect/widgets/ads_widget.dart';
import 'package:culinect/widgets/friend_suggestions_widget.dart';
import 'package:flutter/material.dart';

class LargeScreenLayout extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onDestinationSelected;
  final Widget bodyContent;
  final Widget largeScreenNavRail;
  final Widget floatingActionButton;

  const LargeScreenLayout({
    Key? key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.bodyContent,
    required this.largeScreenNavRail,
    required this.floatingActionButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          largeScreenNavRail,
          Expanded(
            child: bodyContent,
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.25,
            child: const Column(
              children: [
                Expanded(
                  child: FriendSuggestionsWidget(),
                ),
                Divider(),
                Expanded(
                  child: AdsWidget(),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      drawer: buildCreateDrawer(context, true), // Adjust the theme as required
    );
  }
}
