import 'package:flutter/material.dart';

Widget headerImage(String imagePath) {
  return Padding(
    padding: const EdgeInsets.all(20),
    child: AspectRatio(
      aspectRatio: 1,
      child: Image.asset(imagePath),
    ),
  );
}

Widget sideImage(String imagePath) {
  return Padding(
    padding: const EdgeInsets.all(20),
    child: AspectRatio(
      aspectRatio: 1,
      child: Image.asset(imagePath),
    ),
  );
}

Widget headerIcon(IconData iconData) {
  return Padding(
    padding: const EdgeInsets.all(20),
    child: Icon(
      iconData,
      size: 100,
    ),
  );
}

Widget sideIcon(IconData iconData) {
  return Padding(
    padding: const EdgeInsets.all(20),
    child: Icon(
      iconData,
      size: 100,
    ),
  );
}
