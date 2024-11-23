import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/notification_model.dart';

class CulinectNotificationService extends ChangeNotifier {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  final _firestore = FirebaseFirestore.instance;

  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;

  Future<void> initialize() async {
    await _firebaseMessaging.requestPermission();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _localNotifications.initialize(
      InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    FirebaseMessaging.onMessage.listen(showNotification);
    _listenToNotifications();
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      final data = json.decode(response.payload!);
      // Handle notification tap
      if (data['messageId'] != null) {
        // Navigate to relevant screen
      }
    }
  }

  void showNotification(RemoteMessage message) {
    _localNotifications.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'default_channel',
          'Default Channel',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: json.encode(message.data),
    );
  }

  void _listenToNotifications() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen((snapshot) {
        _notifications = snapshot.docs
            .map((doc) =>
                NotificationModel.fromJson({...doc.data(), 'id': doc.id}))
            .toList();
        notifyListeners();
      });
    }
  }

  Stream<List<NotificationModel>> getNotificationStream() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                NotificationModel.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  Stream<int> get unreadCount {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'read': true, 'readAt': FieldValue.serverTimestamp()});
      _updateLocalNotification(notificationId, isRead: true);
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final batch = _firestore.batch();
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('read', isEqualTo: false)
          .get();

      for (var doc in querySnapshot.docs) {
        batch.update(doc.reference, {
          'read': true,
          'readAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      _notifications = _notifications.map((n) => n..isRead = true).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting notification: $e');
    }
  }

  void _updateLocalNotification(String notificationId, {bool? isRead}) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      if (isRead != null) _notifications[index].isRead = isRead;
      notifyListeners();
    }
  }
}
