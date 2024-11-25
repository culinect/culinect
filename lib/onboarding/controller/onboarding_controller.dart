import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:culinect/auth/models/app_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingController extends GetxController {
  final currentPage = 0.obs;
  final pageController = PageController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final Rx<AppUser> user = AppUser(
    basicInfo: UserBasicInfo(
      uid: FirebaseAuth.instance.currentUser?.uid ?? '',
      fullName: '',
      email: '',
      phoneNumber: '',
      profilePicture: '',
      profileLink: '',
      role: '',
    ),
    extendedInfo: UserExtendedInfo(
      bio: '',
      joinedAt: DateTime.now(),
      resumeId: '',
      postCount: 0,
      recipeCount: 0,
      jobsCount: 0,
      username: '',
      followersCount: 0,
      followingCount: 0,
      savedPosts: [],
      postLinks: {},
    ),
    fcmTokens: [],
  ).obs;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasProfileImage = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userData =
            await _firestore.collection('users').doc(currentUser.uid).get();
        if (userData.exists) {
          user.value = AppUser.fromMap(userData.data()!);
        }
      }
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }

  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      final updatedBasicInfo = user.value.basicInfo.copyWith(
        uid: user.value.basicInfo.uid,
        fullName: data['fullName'] ?? user.value.basicInfo.fullName,
        email: user.value.basicInfo.email,
        phoneNumber: user.value.basicInfo.phoneNumber,
        profilePicture: user.value.basicInfo.profilePicture,
        profileLink: user.value.basicInfo.profileLink,
        role: user.value.basicInfo.role,
        professionalTitle: data['professionalTitle'],
        currentWorkplace: data['currentWorkplace'],
        specialties: data['specialties'],
        yearsExperience: data['yearsExperience'],
      );

      final updatedUser = AppUser(
        basicInfo: updatedBasicInfo,
        extendedInfo: user.value.extendedInfo,
        fcmTokens: user.value.fcmTokens,
      );

      await _firestore
          .collection('users')
          .doc(updatedBasicInfo.uid)
          .update(updatedUser.toMap());

      user.value = updatedUser;
      nextPage();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> uploadProfileImage(File imageFile) async {
    try {
      isLoading.value = true;
      final ref =
          _storage.ref().child('profile_images/${user.value.basicInfo.uid}');
      await ref.putFile(imageFile);
      final url = await ref.getDownloadURL();

      final updatedBasicInfo = UserBasicInfo(
        uid: user.value.basicInfo.uid,
        fullName: user.value.basicInfo.fullName,
        email: user.value.basicInfo.email,
        phoneNumber: user.value.basicInfo.phoneNumber,
        profilePicture: url,
        profileLink: user.value.basicInfo.profileLink,
        role: user.value.basicInfo.role,
        professionalTitle: user.value.basicInfo.professionalTitle,
        currentWorkplace: user.value.basicInfo.currentWorkplace,
        specialties: user.value.basicInfo.specialties,
        yearsExperience: user.value.basicInfo.yearsExperience,
      );

      final updatedUser = AppUser(
        basicInfo: updatedBasicInfo,
        extendedInfo: user.value.extendedInfo,
        fcmTokens: user.value.fcmTokens,
      );

      await _firestore
          .collection('users')
          .doc(user.value.basicInfo.uid)
          .update({'profilePicture': url});

      user.value = updatedUser;
      hasProfileImage.value = true;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void nextPage() {
    if (currentPage.value < 3) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      currentPage.value++;
    } else {
      completeOnboarding();
    }
  }

  Future<void> completeOnboarding() async {
    try {
      isLoading.value = true;
      final updatedExtendedInfo = user.value.extendedInfo.copyWith(
        isProfileComplete: true,
      );

      final updatedUser = AppUser(
        basicInfo: user.value.basicInfo,
        extendedInfo: updatedExtendedInfo,
        fcmTokens: user.value.fcmTokens,
      );

      await _firestore
          .collection('users')
          .doc(user.value.basicInfo.uid)
          .update({'isProfileComplete': true});

      user.value = updatedUser;
      Get.offAllNamed('/home');
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void skipOnboarding() {
    Get.offAllNamed('/home');
  }
}
