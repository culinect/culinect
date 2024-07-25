import '../../imports.dart';

class Conversation {
  final String conversationId;
  final List<String> participants;
  final DateTime lastMessageTimestamp;
  final String lastMessageContent;

  Conversation({
    required this.conversationId,
    required this.participants,
    required this.lastMessageTimestamp,
    required this.lastMessageContent,
  });

  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      conversationId: map['conversationId'],
      participants: List<String>.from(map['participants']),
      lastMessageTimestamp: (map['lastMessageTimestamp'] as Timestamp).toDate(),
      lastMessageContent: map['lastMessageContent'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'conversationId': conversationId,
      'participants': participants,
      'lastMessageTimestamp': lastMessageTimestamp,
      'lastMessageContent': lastMessageContent,
    };
  }
}
