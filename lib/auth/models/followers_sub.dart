import 'package:cloud_firestore/cloud_firestore.dart';

class Follower {
  final String followerUid;
  final DateTime timestamp;

  Follower({
    required this.followerUid,
    required this.timestamp,
  });

  factory Follower.fromMap(Map<String, dynamic> data) {
    return Follower(
      followerUid: data['followerUid'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'followerUid': followerUid,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
