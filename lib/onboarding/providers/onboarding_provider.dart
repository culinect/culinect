import 'package:culinect/auth/models/app_user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:culinect/onboarding/controller/onboarding_controller.dart';

final onboardingProvider =
    StateNotifierProvider<OnboardingController, OnboardingState>((ref) {
  return OnboardingController();
});

class OnboardingState {
  final int currentStep;
  final AppUser userData;
  final bool isLoading;
  final String? error;

  OnboardingState({
    required this.currentStep,
    required this.userData,
    this.isLoading = false,
    this.error,
  });

  OnboardingState copyWith({
    int? currentStep,
    AppUser? userData,
    bool? isLoading,
    String? error,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      userData: userData ?? this.userData,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
