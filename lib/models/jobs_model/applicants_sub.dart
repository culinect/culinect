import 'package:cloud_firestore/cloud_firestore.dart';

class JobApplicant {
  final String userId; // User ID of the applicant
  final String resumeLink; // Link to the applicant's resume
  final String applicationMethod; // How the applicant applied (email, app, career page)
  final DateTime applicationDate; // Date when the application was submitted

  JobApplicant({
    required this.userId,
    required this.resumeLink,
    required this.applicationMethod,
    required this.applicationDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'resumeLink': resumeLink,
      'applicationMethod': applicationMethod,
      'applicationDate': Timestamp.fromDate(applicationDate),
    };
  }

  factory JobApplicant.fromMap(Map<String, dynamic> data) {
    return JobApplicant(
      userId: data['userId'] ?? '',
      resumeLink: data['resumeLink'] ?? '',
      applicationMethod: data['applicationMethod'] ?? '',
      applicationDate: (data['applicationDate'] != null && data['applicationDate'] is Timestamp)
          ? (data['applicationDate'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
