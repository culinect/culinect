import 'package:flutter/material.dart';
import 'package:culinect/user/ResumeBuilderScreen.dart';
import 'package:culinect/user/ResumeViewScreen.dart';
import 'package:share_plus/share_plus.dart';

class UserInfoPanel extends StatelessWidget {
  final String profilePicture;
  final String fullName;
  final String bio;
  final String location;
  final bool isFollowing;
  final VoidCallback onFollowButtonPressed;
  final int followersCount;
  final int followingCount;
  final bool showFollowButton;
  final String profileLink;

  const UserInfoPanel({
    Key? key,
    required this.profilePicture,
    required this.fullName,
    required this.bio,
    required this.location,
    required this.isFollowing,
    required this.onFollowButtonPressed,
    required this.followersCount,
    required this.followingCount,
    required this.showFollowButton,
    required this.profileLink,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(profilePicture),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      bio,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      location,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to the resume screen or handle view resume action
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResumeViewScreen(),
                        ),
                      );
                    },
                    child: const Text('View Resume'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      Share.share(profileLink);
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatColumn('Followers', followersCount),
              _buildStatColumn('Following', followingCount),
            ],
          ),
          const SizedBox(height: 16),
          if (showFollowButton)
            Center(
              child: ElevatedButton(
                onPressed: onFollowButtonPressed,
                child: Text(isFollowing ? 'Unfollow' : 'Follow'),
              ),
            ),
        ],
      ),
    );
  }

  Column _buildStatColumn(String label, int count) {
    return Column(
      children: [
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
