import 'package:culinect/create/job_create.dart';
import 'package:culinect/create/post_create.dart';
import 'package:culinect/create/recipe_create.dart';
import 'package:flutter/material.dart';

Widget buildCreateDrawer(BuildContext context, bool isLightTheme) {
  return Drawer(
    child: ListView(
      children: [
        DrawerHeader(
          child: Text('CuliNect Menu'),
          decoration: BoxDecoration(
            color: isLightTheme ? Colors.white54 : Colors.grey[400],
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
          widget: Container(), // Placeholder for Blog Post functionality
        ),
      ],
    ),
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
      style: TextStyle(color: Theme.of(context).primaryColor),
    ),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => widget),
      );
    },
  );
}
