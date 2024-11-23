import 'package:culinect/models/notification_model.dart';
import 'package:culinect/services/notification_service.dart';
import 'package:culinect/widgets/notification_icon.dart';
import 'package:provider/provider.dart';

import '../imports.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationTile({
    Key? key,
    required this.notification,
    required this.onTap,
  }) : super(key: key);

  String _getFormattedTime() {
    final now = DateTime.now();
    final difference = now.difference(notification.createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        context
            .read<CulinectNotificationService>()
            .deleteNotification(notification.id);
      },
      child: ListTile(
        leading: NotificationIcon(type: notification.type),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight:
                notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.body),
            const SizedBox(height: 4),
            Text(
              _getFormattedTime(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        tileColor: notification.isRead ? null : Colors.blue.withOpacity(0.05),
        onTap: onTap,
      ),
    );
  }
}
