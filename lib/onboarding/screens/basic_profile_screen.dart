import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/onboarding_controller.dart';
import '../widgets/profile_image_picker.dart';

class BasicProfileScreen extends StatefulWidget {
  @override
  State<BasicProfileScreen> createState() => _BasicProfileScreenState();
}

class _BasicProfileScreenState extends State<BasicProfileScreen> {
  final OnboardingController controller = Get.find();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController workplaceController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.text = controller.user.value.basicInfo.fullName;
    titleController.text = controller.user.value.basicInfo.professionalTitle;
    workplaceController.text = controller.user.value.basicInfo.currentWorkplace;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Basic Profile'),
        actions: [
          TextButton(
            onPressed: controller.skipOnboarding,
            child: const Text('Skip'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ProfileImagePicker(
                  onImageSelected: controller.uploadProfileImage,
                  currentImageUrl:
                      controller.user.value.basicInfo.profilePicture,
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Professional Title',
                  prefixIcon: Icon(Icons.work),
                  hintText: 'e.g., Executive Chef, Sous Chef',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: workplaceController,
                decoration: const InputDecoration(
                  labelText: 'Current Workplace',
                  prefixIcon: Icon(Icons.business),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 32),
              Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                            if (_formKey.currentState?.validate() ?? false) {
                              controller.updateUserProfile({
                                'displayName': nameController.text,
                                'professionalTitle': titleController.text,
                                'currentWorkplace': workplaceController.text,
                                'location': locationController.text,
                              });
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator()
                        : const Text(
                            'Continue',
                            style: TextStyle(fontSize: 18),
                          ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    titleController.dispose();
    workplaceController.dispose();
    locationController.dispose();
    super.dispose();
  }
}
