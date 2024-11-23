import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FriendSuggestionsWidget extends StatefulWidget {
  const FriendSuggestionsWidget({super.key});

  @override
  _FriendSuggestionsWidgetState createState() =>
      _FriendSuggestionsWidgetState();
}

class _FriendSuggestionsWidgetState extends State<FriendSuggestionsWidget> {
  List<DocumentSnapshot> suggestedFriends = [];

  @override
  void initState() {
    super.initState();
    _fetchFriendSuggestions();
  }

  Future<void> _fetchFriendSuggestions() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', isNotEqualTo: user.uid)
          .limit(5)
          .get();
      setState(() {
        suggestedFriends = snapshot.docs;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(
            title: Text(
              'Friend Suggestions',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: suggestedFriends.length,
              itemBuilder: (context, index) {
                DocumentSnapshot friend = suggestedFriends[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage:
                        NetworkImage(friend['profilePicture'] ?? ''),
                  ),
                  title: Text(friend['fullName'] ?? 'Unknown'),
                  subtitle: Text(friend['email'] ?? ''),
                  trailing: ElevatedButton(
                    onPressed: () {
                      // Handle friend request logic
                    },
                    child: const Text('Add Friend'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
