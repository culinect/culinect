import 'package:cloud_firestore/cloud_firestore.dart';

class Following {
  final String followingUid;
  final DateTime timestamp;

  Following({
    required this.followingUid,
    required this.timestamp,
  });

  factory Following.fromMap(Map<String, dynamic> data) {
    return Following(
      followingUid: data['followingUid'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'followingUid': followingUid,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
