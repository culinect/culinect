import 'package:culinect/models/notification_model.dart';
import 'package:culinect/services/notification_service.dart';
import 'package:provider/provider.dart';

import '../imports.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notificationService =
        Provider.of<CulinectNotificationService>(context);
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            onPressed: () {
              if (currentUser != null) {
                notificationService.markAllNotificationsAsRead();
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: currentUser?.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: snapshot.data!.docs.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final notification = NotificationModel.fromJson(
                doc.data() as Map<String, dynamic>,
              );

              return NotificationTile(
                notification: notification,
                onTap: () => _handleNotificationTap(context, notification),
              );
            },
          );
        },
      ),
    );
  }

  void _handleNotificationTap(
      BuildContext context, NotificationModel notification) async {
    final notificationService = Provider.of<CulinectNotificationService>(
      context,
      listen: false,
    );

    if (!notification.isRead) {
      await notificationService.markNotificationAsRead(notification.id);
    }
    switch (notification.type) {
      case 'new_message':
        if (notification.messageId != null) {
          Navigator.pushNamed(
            context,
            '/chat',
            arguments: {'chatId': notification.messageId},
          );
        }
        break;
      case 'recipe':
        if (notification.messageId != null) {
          Navigator.pushNamed(
            context,
            '/recipe-details',
            arguments: {'recipeId': notification.messageId},
          );
        }
        break;
      case 'post':
        if (notification.messageId != null) {
          Navigator.pushNamed(
            context,
            '/post-details',
            arguments: {'postId': notification.messageId},
          );
        }
        break;
      case 'job':
        if (notification.messageId != null) {
          Navigator.pushNamed(
            context,
            '/job-details',
            arguments: {'jobId': notification.messageId},
          );
        }
        break;
      default:
        break;
    }
  }
}

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationTile({
    Key? key,
    required this.notification,
    required this.onTap,
  }) : super(key: key);

  Widget _getNotificationIcon() {
    IconData iconData;
    Color iconColor;

    switch (notification.type) {
      case 'new_message':
        iconData = Icons.message;
        iconColor = Colors.blue;
        break;
      case 'recipe':
        iconData = Icons.restaurant_menu;
        iconColor = Colors.orange;
        break;
      case 'post':
        iconData = Icons.post_add;
        iconColor = Colors.green;
        break;
      case 'job':
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
        Provider.of<CulinectNotificationService>(context, listen: false)
            .deleteNotification(notification.id);
      },
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: _getNotificationIcon(),
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
