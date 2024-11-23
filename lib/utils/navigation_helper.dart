import 'package:culinect/constants/notification_types.dart';
import 'package:culinect/models/notification_model.dart';

import '../imports.dart';

class NavigationHelper {
  static void handleNotificationNavigation(
      BuildContext context, NotificationModel notification) {
    switch (notification.type) {
      case NotificationType.newMessage:
        if (notification.senderId != null) {
          Navigator.pushNamed(context, '/users/${notification.senderId}');
        }
        break;
      case NotificationType.recipe:
      case NotificationType.post:
      case NotificationType.job:
        if (notification.messageId != null) {
          Navigator.pushNamed(context,
              '/${notification.type}-details/${notification.messageId}');
        }
        break;
    }
  }
}
