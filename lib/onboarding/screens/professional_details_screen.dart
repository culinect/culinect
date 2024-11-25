import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/onboarding_controller.dart';
import '../widgets/specialty_selector.dart';

class ProfessionalDetailsScreen extends StatefulWidget {
  @override
  State<ProfessionalDetailsScreen> createState() =>
      _ProfessionalDetailsScreenState();
}

class _ProfessionalDetailsScreenState extends State<ProfessionalDetailsScreen> {
  final OnboardingController controller = Get.find();
  final _formKey = GlobalKey<FormState>();
  final List<String> selectedSpecialties = [];
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController certificationsController =
      TextEditingController();
  final TextEditingController educationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    experienceController.text =
        controller.user.value.yearsOfExperience.toString();
    selectedSpecialties.addAll(controller.user.value.specialties);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Professional Details'),
        actions: [
          TextButton(
            onPressed: controller.nextPage,
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
              Text(
                'Your Expertise',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              SpecialtySelector(
                selectedSpecialties: selectedSpecialties,
                onSpecialtiesChanged: (specialties) {
                  setState(() {
                    selectedSpecialties.clear();
                    selectedSpecialties.addAll(specialties);
                  });
                },
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: experienceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Years of Experience',
                  prefixIcon: Icon(Icons.timeline),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: certificationsController,
                decoration: const InputDecoration(
                  labelText: 'Certifications',
                  prefixIcon: Icon(Icons.verified),
                  hintText: 'e.g., ServSafe, ACF Certification',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: educationController,
                decoration: const InputDecoration(
                  labelText: 'Education',
                  prefixIcon: Icon(Icons.school),
                  hintText: 'e.g., Culinary Institute of America',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                            if (_formKey.currentState?.validate() ?? false) {
                              controller.updateUserProfile({
                                'specialties': selectedSpecialties,
                                'yearsOfExperience':
                                    int.tryParse(experienceController.text) ??
                                        0,
                                'certifications':
                                    certificationsController.text.split('\n'),
                                'education':
                                    educationController.text.split('\n'),
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
    experienceController.dispose();
    certificationsController.dispose();
    educationController.dispose();
    super.dispose();
  }
}
