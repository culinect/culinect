import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller/onboarding_controller.dart';
import 'screens/basic_profile_screen.dart';
import 'screens/interests_screen.dart';
import 'screens/professional_details_screen.dart';
import 'screens/welcome_screen.dart';

class OnboardingFlow extends StatelessWidget {
  OnboardingFlow({Key? key}) : super(key: key);

  final OnboardingController controller = Get.put(OnboardingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: controller.pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              WelcomeScreen(),
              BasicProfileScreen(),
              ProfessionalDetailsScreen(),
              InterestsScreen(),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 0,
            right: 0,
            child: Obx(() => LinearProgressIndicator(
                  value: (controller.currentPage.value + 1) / 4,
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                )),
          ),
        ],
      ),
    );
  }
}
