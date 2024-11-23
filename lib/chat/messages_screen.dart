import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:culinect/auth/models/app_user.dart'; // Import your user model
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'chat_screen.dart';
import 'user_search_screen.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('User not logged in'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('conversations')
            .where('participants', arrayContains: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No messages yet'));
          }

          final conversations = snapshot.data!.docs;

          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              final conversationId = conversation.id;
              final participants =
                  conversation['participants'] as List<dynamic>;
              final lastMessageContent =
                  conversation['lastMessageContent'] ?? '';
              final lastMessageTimestamp =
                  (conversation['lastMessageTimestamp'] as Timestamp).toDate();

              // Fetch user details for the other participant
              final otherUserId =
                  participants.firstWhere((id) => id != user.uid);
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(otherUserId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const ListTile(
                      title: Text('Loading...'),
                    );
                  }

                  final userData =
                      userSnapshot.data!.data() as Map<String, dynamic>;
                  final appUser = AppUser.fromMap(userData);
                  final fullName = appUser.basicInfo.fullName;
                  final profilePicture = appUser.basicInfo.profilePicture;

                  // Debugging statement
                  print('Profile Picture URL: $profilePicture');

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: profilePicture.isNotEmpty
                          ? NetworkImage(profilePicture)
                          : null,
                      child: profilePicture.isEmpty
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    title: Text(fullName),
                    subtitle: Text(lastMessageContent),
                    trailing: Text(
                      '${lastMessageTimestamp.hour}:${lastMessageTimestamp.minute}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            conversationId: conversationId,
                            userId: user.uid,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        backgroundColor: Colors.teal,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UserSearchScreen()),
          );
        },
      ),
    );
  }
}
