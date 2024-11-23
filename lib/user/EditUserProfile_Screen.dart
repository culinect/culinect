import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:culinect/auth/models/app_user.dart';
import 'package:culinect/user/ResumeBuilderScreen.dart';
import 'package:flutter/material.dart';

class EditUserProfileScreen extends StatefulWidget {
  final String userId;

  EditUserProfileScreen({required this.userId});

  @override
  _EditUserProfileScreenState createState() => _EditUserProfileScreenState();
}

class _EditUserProfileScreenState extends State<EditUserProfileScreen> {
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _profileLinkController;
  late TextEditingController _bioController;
  late TextEditingController _usernameController;
  late AppUser _appUser;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();

    if (userDoc.exists) {
      _appUser = AppUser.fromMap(userDoc.data() as Map<String, dynamic>);
      _initializeControllers();
      setState(() {});
    }
  }

  void _initializeControllers() {
    _fullNameController =
        TextEditingController(text: _appUser.basicInfo.fullName);
    _emailController = TextEditingController(text: _appUser.basicInfo.email);
    _phoneController =
        TextEditingController(text: _appUser.basicInfo.phoneNumber);
    _profileLinkController =
        TextEditingController(text: _appUser.basicInfo.profileLink);
    _bioController = TextEditingController(text: _appUser.extendedInfo.bio);
    _usernameController =
        TextEditingController(text: _appUser.extendedInfo.username);
  }

  void _saveProfile() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .update({
      'fullName': _fullNameController.text,
      'email': _emailController.text,
      'phoneNumber': _phoneController.text,
      'profileLink': _profileLinkController.text,
      'bio': _bioController.text,
      'username': _usernameController.text,
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: _appUser != null
          ? SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Picture with Edit Option
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage:
                              NetworkImage(_appUser.basicInfo.profilePicture),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: IconButton(
                            icon: Icon(Icons.edit, color: Colors.cyanAccent),
                            onPressed: () {
                              // Add logic to update profile picture
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.0),
                  _buildReadOnlyField('Role', _appUser.basicInfo.role),
                  _buildReadOnlyField('Joined At',
                      _appUser.extendedInfo.joinedAt.toLocal().toString()),
                  _buildEditableField('Full Name', _fullNameController),
                  _buildEditableField('Email', _emailController),
                  _buildEditableField('Phone Number', _phoneController),
                  _buildEditableField('Profile Link', _profileLinkController),
                  _buildEditableField('Bio', _bioController),
                  _buildEditableField('Username', _usernameController),

                  SizedBox(height: 16.0),
                  // Edit Resume Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ResumeBuilderScreen()),
                      );
                    },
                    child: Text('Edit Resume'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyanAccent),
                  ),
                ],
              ),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          hintText: value,
        ),
      ),
    );
  }
}
