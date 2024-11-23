import 'package:culinect/constants/notification_types.dart';

import '../imports.dart';

class NotificationIcon extends StatelessWidget {
  final String type;

  const NotificationIcon({Key? key, required this.type}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case NotificationType.newMessage:
        iconData = Icons.message;
        iconColor = Colors.blue;
        break;
      case NotificationType.recipe:
        iconData = Icons.restaurant_menu;
        iconColor = Colors.orange;
        break;
      case NotificationType.post:
        iconData = Icons.post_add;
        iconColor = Colors.green;
        break;
      case NotificationType.job:
        iconData = Icons.work;
        iconColor = Colors.purple;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = Colors.grey;
    }

    return CircleAvatar(
      backgroundColor: iconColor.withOpacity(0.1),
      child: Icon(iconData, color: iconColor),
    );
  }
}
