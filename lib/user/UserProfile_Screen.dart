import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:culinect/auth/models/app_user.dart';
import 'package:culinect/models/jobs_model/job.dart';
import 'package:culinect/models/posts/posts.dart';
import 'package:culinect/models/recipes/recipe.dart';
import 'package:culinect/user/ResumeBuilderScreen.dart';
import 'package:culinect/widgets/user_info_panel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late Future<AppUser> _userDoc;
  late Future<List<Job>> _jobs;
  late Future<List<Posts>> _posts;
  late Future<List<Recipe>> _recipes;
  bool isFollowing = false;
  bool isOwnProfile = false;

  @override
  void initState() {
    super.initState();
    _userDoc = _fetchUserData();
    _jobs = _fetchJobs();
    _posts = _fetchPosts();
    _recipes = _fetchRecipes();
    _checkFollowingStatus();
    _checkIfOwnProfile();
  }

  Future<AppUser> _fetchUserData() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();
    return AppUser.fromMap(snapshot.data() as Map<String, dynamic>);
  }

  Future<List<Job>> _fetchJobs() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('jobs')
        .where('author.userId', isEqualTo: widget.userId)
        .get();
    return snapshot.docs
        .map((doc) => Job.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<List<Posts>> _fetchPosts() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('author.userId', isEqualTo: widget.userId)
        .get();
    return snapshot.docs
        .map((doc) => Posts.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<List<Recipe>> _fetchRecipes() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('recipes')
        .where('author', isEqualTo: widget.userId)
        .get();
    return snapshot.docs
        .map((doc) => Recipe.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  void _checkFollowingStatus() async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();
    setState(() {
      isFollowing = (userDoc.data() as Map<String, dynamic>)['followers']
          .contains(currentUserId);
    });
  }

  void _checkIfOwnProfile() {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    setState(() {
      isOwnProfile = currentUserId == widget.userId;
    });
  }

  void _toggleFollow() async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(widget.userId);
    DocumentSnapshot userDoc = await userRef.get();

    setState(() {
      isFollowing = !isFollowing;
    });

    if (isFollowing) {
      userRef.update({
        'followers': FieldValue.arrayUnion([currentUserId]),
      });
    } else {
      userRef.update({
        'followers': FieldValue.arrayRemove([currentUserId]),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: FutureBuilder<AppUser>(
        future: _userDoc,
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!userSnapshot.hasData || userSnapshot.hasError) {
            return const Center(child: Text('Error fetching user data'));
          }

          var user = userSnapshot.data!;
          var userInfo = user.basicInfo;
          var extendedInfo = user.extendedInfo;

          return Column(
            children: [
              UserInfoPanel(
                profilePicture: userInfo.profilePicture,
                fullName: userInfo.fullName,
                bio: extendedInfo.bio,
                location: '', // Add location if available
                isFollowing: isFollowing,
                onFollowButtonPressed: _toggleFollow,
                followersCount: extendedInfo.followersCount,
                followingCount: extendedInfo.followingCount,
                showFollowButton: !isOwnProfile,
                profileLink: userInfo.profileLink, // Pass profile link
              ),
              Expanded(
                child: DefaultTabController(
                  length: 4,
                  child: Column(
                    children: [
                      TabBar(
                        tabs: [
                          Tab(
                            icon: Icon(Icons.post_add),
                            text: 'Posts (${extendedInfo.postCount})',
                          ),
                          Tab(
                            icon: Icon(Icons.receipt),
                            text: 'Recipes (${extendedInfo.recipeCount})',
                          ),
                          Tab(
                            icon: Icon(Icons.work),
                            text: 'Jobs (${extendedInfo.jobsCount})',
                          ),
                          Tab(
                            icon: Icon(Icons.article),
                            text:
                                'Blogs (0)', // Update if blogs count is available
                          ),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildPostsTab(),
                            _buildRecipesTab(),
                            _buildJobsTab(),
                            _buildBlogsTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: isOwnProfile
          ? FloatingActionButton(
              onPressed: () {
                // Navigate to edit profile screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ResumeBuilderScreen(), // Navigate to RecipeCreateScreen
                    //ResumeViewScreen(),
                  ),
                );
              },
              child: const Icon(Icons.edit),
            )
          : null,
    );
  }

  Widget _buildPostsTab() {
    return FutureBuilder<List<Posts>>(
      future: _posts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.hasError) {
          return const Center(child: Text('No posts available'));
        }

        var posts = snapshot.data!;
        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            var post = posts[index];
            return ListTile(
              title: Text(post.content),
              subtitle: Text(post.getCreatedTimeAgo()),
            );
          },
        );
      },
    );
  }

  Widget _buildRecipesTab() {
    return FutureBuilder<List<Recipe>>(
      future: _recipes,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.hasError) {
          return const Center(child: Text('No recipes available'));
        }

        var recipes = snapshot.data!;
        return ListView.builder(
          itemCount: recipes.length,
          itemBuilder: (context, index) {
            var recipe = recipes[index];
            return ListTile(
              title: Text(recipe.title ?? ''),
              subtitle: Text(recipe.description ?? ''),
            );
          },
        );
      },
    );
  }

  Widget _buildJobsTab() {
    return FutureBuilder<List<Job>>(
      future: _jobs,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.hasError) {
          return const Center(child: Text('No jobs available'));
        }

        var jobs = snapshot.data!;
        return ListView.builder(
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            var job = jobs[index];
            return ListTile(
              title: Text(job.title),
              subtitle: Text(job.company.companyName),
            );
          },
        );
      },
    );
  }

  Widget _buildBlogsTab() {
    // Placeholder for blogs, as the Blog model and fetching logic are not provided.
    return const Center(child: Text('No blogs available'));
  }
}
