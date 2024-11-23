import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String body;
  final String? messageId;
  final String? senderId;
  final DateTime createdAt;
  bool isRead;
  DateTime? readAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.messageId,
    this.senderId,
    required this.createdAt,
    this.isRead = false,
    this.readAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json,
      [String? docId]) {
    return NotificationModel(
      id: docId ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      messageId: json['messageId'],
      senderId: json['senderId'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      isRead: json['read'] ?? false,
      readAt: json['readAt'] != null
          ? (json['readAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'type': type,
      'title': title,
      'body': body,
      'messageId': messageId,
      'senderId': senderId,
      'createdAt': Timestamp.fromDate(createdAt),
      'read': isRead,
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? type,
    String? title,
    String? body,
    String? messageId,
    String? senderId,
    DateTime? createdAt,
    bool? isRead,
    DateTime? readAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      messageId: messageId ?? this.messageId,
      senderId: senderId ?? this.senderId,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
    );
  }
}
