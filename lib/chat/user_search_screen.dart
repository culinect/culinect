import 'dart:math'; // Import this package for using max function

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'chat_screen.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});

  @override
  _UserSearchScreenState createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _searchResults = [];

  void _searchUsers() async {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    final results = await FirebaseFirestore.instance.collection('users').get();
    final filteredResults = results.docs.where((doc) {
      if (!doc.data().containsKey('fullName')) {
        return false;
      }
      final fullName = doc['fullName'].toString().toLowerCase();
      final similarity = _calculateSimilarity(fullName, query);
      print('Comparing $fullName with $query, similarity: $similarity');
      return similarity >= 0.35;
    }).toList();

    setState(() {
      _searchResults = filteredResults;
    });
  }

  double _calculateSimilarity(String s1, String s2) {
    final lcsLength = _longestCommonSubsequence(s1, s2).length;
    return (2.0 * lcsLength) / (s1.length + s2.length);
  }

  String _longestCommonSubsequence(String s1, String s2) {
    final m = s1.length;
    final n = s2.length;
    final dp =
        List<List<int>>.generate(m + 1, (_) => List<int>.filled(n + 1, 0));

    for (int i = 1; i <= m; i++) {
      for (int j = 1; j <= n; j++) {
        if (s1[i - 1] == s2[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1] + 1;
        } else {
          dp[i][j] = max(dp[i - 1][j], dp[i][j - 1]);
        }
      }
    }

    int i = m, j = n;
    StringBuffer lcs = StringBuffer();

    while (i > 0 && j > 0) {
      if (s1[i - 1] == s2[j - 1]) {
        lcs.write(s1[i - 1]);
        i--;
        j--;
      } else if (dp[i - 1][j] > dp[i][j - 1]) {
        i--;
      } else {
        j--;
      }
    }

    return lcs.toString().split('').reversed.join();
  }

  void _startConversation(String otherUserId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Check if a conversation already exists
      final existingConversations = await FirebaseFirestore.instance
          .collection('conversations')
          .where('participants', arrayContains: user.uid)
          .get();

      for (var doc in existingConversations.docs) {
        if ((doc['participants'] as List<dynamic>).contains(otherUserId)) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                conversationId: doc.id,
                userId: user.uid,
              ),
            ),
          );
          return;
        }
      }

      // If no conversation exists, create a new one
      final newConversation =
          await FirebaseFirestore.instance.collection('conversations').add({
        'participants': [user.uid, otherUserId],
        'lastMessageContent': '',
        'lastMessageTimestamp': Timestamp.now(),
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            conversationId: newConversation.id,
            userId: user.uid,
          ),
        ),
      );
    } catch (e) {
      print('Error starting conversation: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start New Conversation'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by full name',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchUsers,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final user = _searchResults[index];
                return ListTile(
                  title: Text(user['fullName']),
                  subtitle: Text(user['email']),
                  onTap: () {
                    print('Tapped on user: ${user['fullName']}');
                    _startConversation(user.id);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
