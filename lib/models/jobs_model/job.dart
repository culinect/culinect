import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:culinect/auth/models/app_user.dart';

class Job {
  final String jobId;
  final UserBasicInfo authorBasicInfo;
  late String title; // Remove 'final'
  late String description; // Remove 'final'
  late String requirements; // Remove 'final'
  final Company company;
  late String location; // Remove 'final'
  late final int salary;
  final DateTime postedDate;
  String applicationMethod;
  String? email;
  String? careerPageUrl;
  late final String jobType;
  late final DateTime applicationDeadline;
  late final String skillsRequired;
  int applicantsCount;
  late final bool remoteWorkOption;

  Job({
    required this.jobId,
    required this.authorBasicInfo,
    required this.title,
    required this.description,
    required this.requirements,
    required this.company,
    required this.location,
    required this.salary,
    required this.postedDate,
    required this.applicationMethod,
    this.email,
    this.careerPageUrl,
    required this.jobType,
    required this.applicationDeadline,
    required this.skillsRequired,
    required this.applicantsCount,
    required this.remoteWorkOption,
  });

  factory Job.fromMap(Map<String, dynamic> data, String jobId) {
    return Job(
      jobId: jobId,
      authorBasicInfo: UserBasicInfo(
        uid: data['author']['userId'] ?? '',
        fullName: data['author']['username'] ?? '',
        email: '',
        phoneNumber: '',
        profilePicture: data['author']['profilePicture'] ?? '',
        profileLink: '',
        role: data['role'],
      ),
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      requirements: data['requirements'] ?? '',
      company: Company.fromMap(data['company']),
      location: data['location'] ?? '',
      salary: data['salary'] ?? 0,
      postedDate: (data['postedDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      applicationMethod: data['applicationMethod'] ?? '',
      email: data['email'],
      careerPageUrl: data['careerPageUrl'],
      jobType: data['jobType'] ?? '',
      applicationDeadline: (data['applicationDeadline'] as Timestamp?)?.toDate() ?? DateTime.now(),
      skillsRequired: data['skillsRequired'] ?? '',
      applicantsCount: data['applicantsCount'] ?? 0,
      remoteWorkOption: data['remoteWorkOption'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'author': {
        'userId': authorBasicInfo.uid,
        'fullName': authorBasicInfo.fullName,
        'profilePicture': authorBasicInfo.profilePicture,
      },
      'title': title,
      'description': description,
      'requirements': requirements,
      'company': company.toMap(),
      'location': location,
      'salary': salary,
      'postedDate': Timestamp.fromDate(postedDate),
      'applicationMethod': applicationMethod,
      'email': email,
      'careerPageUrl': careerPageUrl,
      'jobType': jobType,
      'applicationDeadline': Timestamp.fromDate(applicationDeadline),
      'skillsRequired': skillsRequired,
      'applicantsCount': applicantsCount,
      'remoteWorkOption': remoteWorkOption,
    };
  }
}

class Company {
  final String companyId;
  late String companyName; // Remove 'final'
  late String companyLogoUrl; // Remove 'final'
  final String? socialMediaLink;

  Company({
    required this.companyId,
    required this.companyName,
    required this.companyLogoUrl,
    this.socialMediaLink,
  });

  factory Company.fromMap(Map<String, dynamic> data) {
    return Company(
      companyId: data['companyId'] ?? '',
      companyName: data['companyName'] ?? '',
      companyLogoUrl: data['companyLogoUrl'] ?? '',
      socialMediaLink: data['socialMediaLink'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'companyId': companyId,
      'companyName': companyName,
      'companyLogoUrl': companyLogoUrl,
      'socialMediaLink': socialMediaLink,
    };
  }
}
