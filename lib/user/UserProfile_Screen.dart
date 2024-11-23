import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:culinect/auth/models/app_user.dart';
import 'package:culinect/models/jobs_model/job.dart';
import 'package:culinect/models/posts/posts.dart';
import 'package:culinect/models/recipes/recipe.dart';
import 'package:culinect/user/EditUserProfile_Screen.dart';
import 'package:culinect/user/ResumeBuilderScreen.dart';
import 'package:culinect/user/ResumeViewScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

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

  void _editProfile() {
    // Navigate to edit profile screen logic
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditUserProfileScreen(userId: widget.userId),
      ),
    );
  }

  void _shareProfile(String profileLink) {
    Share.share(profileLink);
  }

  void _openResumeScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            isOwnProfile ? ResumeBuilderScreen() : ResumeViewScreen(),
      ),
    );
  }

  Widget _buildStatColumn(String label, int count) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<AppUser>(
          future: _userDoc,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading...');
            } else if (snapshot.hasError) {
              return const Text('Error');
            } else {
              return Text(snapshot.data?.basicInfo.fullName ?? 'User Profile');
            }
          },
        ),
        actions: [
          if (isOwnProfile)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _editProfile,
            ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _userDoc
                .then((user) => _shareProfile(user.basicInfo.profileLink)),
          ),
          IconButton(
            icon: Icon(isOwnProfile ? Icons.edit_note : Icons.article),
            onPressed: _openResumeScreen,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isLargeScreen = constraints.maxWidth > 768;
          return isLargeScreen
              ? _buildDesktopLayout(context)
              : _buildMobileLayout(context);
        },
      ),
    );
  }

  // Desktop layout
  Widget _buildDesktopLayout(BuildContext context) {
    return FutureBuilder<AppUser>(
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

        return Row(
          children: [
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage:
                          NetworkImage(userInfo.profilePicture ?? ''),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      userInfo.fullName,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      extendedInfo.bio ?? 'No bio available',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatColumn(
                            "Followers", extendedInfo.followersCount),
                        _buildStatColumn(
                            "Following", extendedInfo.followingCount),
                      ],
                    ),
                    if (!isOwnProfile)
                      ElevatedButton(
                        onPressed: _toggleFollow,
                        child: Text(isFollowing ? 'Unfollow' : 'Follow'),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
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
                          text: 'Blogs (0)',
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
    );
  }

  // Mobile layout
  Widget _buildMobileLayout(BuildContext context) {
    return FutureBuilder<AppUser>(
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

        return SingleChildScrollView(
          child: Column(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(userInfo.profilePicture ?? ''),
              ),
              const SizedBox(height: 16),
              Text(
                userInfo.fullName,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                extendedInfo.bio ?? 'No bio available',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatColumn("Followers", extendedInfo.followersCount),
                  _buildStatColumn("Following", extendedInfo.followingCount),
                ],
              ),
              if (!isOwnProfile)
                ElevatedButton(
                  onPressed: _toggleFollow,
                  child: Text(isFollowing ? 'Unfollow' : 'Follow'),
                ),
              const SizedBox(height: 20),
              DefaultTabController(
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
                          text: 'Blogs (0)',
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 400,
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
            ],
          ),
        );
      },
    );
  }

// Generic Grid Builder
  Widget _buildGridTab<T>(List<T> items, String imageField) {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        String? imageUrl;

        // Dynamically access the image field based on the type of item
        if (item is Posts) {
          imageUrl = item.imageUrls.isNotEmpty
              ? item.imageUrls[0]
              : null; // Access the image URL
        } else if (item is Recipe) {
          imageUrl =
              item.recipeImageUrl; // Assuming recipeImageUrl is a String?
        }

        return imageUrl != null && imageUrl.isNotEmpty
            ? Image.network(imageUrl, fit: BoxFit.cover)
            : Container(
                color: Colors.grey[200],
                child:
                    const Center(child: Icon(Icons.image, color: Colors.grey)),
              );
      },
    );
  }

// Posts Tab
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

        return _buildGridTab(
            snapshot.data!, 'imageUrls'); // Adjust this accordingly if needed
      },
    );
  }

// Recipes Tab
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

        return _buildGridTab(snapshot.data!,
            'recipeImageUrl'); // Adjust this accordingly if needed
      },
    );
  }

// Jobs Tab
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
        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final job = snapshot.data![index];
            return ListTile(
              title: Text(job.title),
              // Display job details
            );
          },
        );
      },
    );
  }

// Blogs Tab
  Widget _buildBlogsTab() {
    //  return FutureBuilder<List<Blog>>(
    //   future: _blogs, // Assuming you have a future for blogs
    //  builder: (context, snapshot) {
    //   if (snapshot.connectionState == ConnectionState.waiting) {
    //    return const Center(child: CircularProgressIndicator());
    // }
    //if (!snapshot.hasData || snapshot.hasError) {
    // return const Center(child: Text('No blogs available'));
    // }

    return Center(
      child: Text(
        'Blogs Feature Coming Soon',
        style: const TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
    //},
    //);
  }
}
