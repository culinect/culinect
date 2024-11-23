import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../auth/models/app_user.dart';
import '../models/notification_model.dart';

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> initialize() async {
    if (kIsWeb) {
      await _initializeWeb();
    } else {
      await _initializeMobile();
    }

    _messaging.onTokenRefresh.listen((newToken) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _updateFCMToken(user.uid, newToken);
      }
    });

    await storeInitialToken();
  }

  static Future<void> _initializeWeb() async {
    // Wait for Firebase Auth to initialize
    await Future.delayed(const Duration(seconds: 2));

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      final token = await _messaging.getToken(
          vapidKey:
              "BOfFs1FcP9sjpHFx3ph6GEQe3x0sU1RS1NJWDV1HxBp8GHxSqWrdmYmqjVGHbE0lrQtCaOKVF5KqFOPC_qEcWQ4");

      if (token != null) {
        await _updateFCMToken(user.uid, token);
        print('FCM Web Token: $token');
      }
    }
  }

  static Future<void> _initializeMobile() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static void onForegroundMessage(void Function(RemoteMessage) callback) {
    FirebaseMessaging.onMessage.listen((message) {
      handleForegroundMessage(message);
      callback(message);
    });
  }

  static Future<void> _updateFCMToken(String userId, String token) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return;

      final user = AppUser.fromMap(userDoc.data()!);
      if (!user.fcmTokens.contains(token)) {
        user.fcmTokens.add(token);
        await _firestore.collection('users').doc(userId).update({
          'fcmTokens': user.fcmTokens,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error updating FCM token: $e');
    }
  }

  static Future<void> subscribeToUserTopic() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _messaging.subscribeToTopic('user_${user.uid}');
    }
  }

  static Future<void> storeInitialToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? token;
      if (kIsWeb) {
        token = await _messaging.getToken(
            vapidKey:
                "BOfFs1FcP9sjpHFx3ph6GEQe3x0sU1RS1NJWDV1HxBp8GHxSqWrdmYmqjVGHbE0lrQtCaOKVF5KqFOPC_qEcWQ4");
      } else {
        token = await _messaging.getToken();
      }

      if (token != null) {
        await _updateFCMToken(user.uid, token);
        print('Initial FCM Token: $token');
      }
    }
  }

  static Future<void> handleForegroundMessage(RemoteMessage message) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final notification = NotificationModel(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      userId: currentUser.uid,
      type: message.data['type'] ?? 'general',
      title: message.notification?.title ?? 'Notification',
      body: message.notification?.body ?? 'You have a new message',
      messageId: message.data['messageId'],
      senderId: message.data['senderId'],
      createdAt: DateTime.now(),
      isRead: false,
    );

    await _firestore.collection('notifications').add(notification.toJson());
  }

  static Future<void> removeToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? token = await _messaging.getToken();
      if (token != null) {
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (!userDoc.exists) return;

        final userData = AppUser.fromMap(userDoc.data()!);
        userData.fcmTokens.remove(token);

        await _firestore.collection('users').doc(user.uid).update({
          'fcmTokens': userData.fcmTokens,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });
      }
    }
  }
}
